using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Database;
using ManiFest.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using EasyNetQ;
using ManiFest.Subscriber.Models;
using ManiFest.Model;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.Extensions.DependencyInjection;

namespace ManiFest.Services.Services
{
    public class FestivalService : BaseCRUDService<FestivalResponse, FestivalSearchObject, Festival, FestivalUpsertRequest, FestivalUpsertRequest>, IFestivalService
    {
        private static MLContext _mlContext = null;
        private static object _mlLock = new object();
        private static ITransformer? _model = null;

        public FestivalService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
            if (_mlContext == null)
            {
                lock (_mlLock)
                {
                    if (_mlContext == null)
                    {
                        _mlContext = new MLContext();
                    }
                }
            }
        }

        protected override IQueryable<Festival> ApplyFilter(IQueryable<Festival> query, FestivalSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(f => f.Title.Contains(search.Title));
            }
            if (search.CityId.HasValue)
            {
                query = query.Where(f => f.CityId == search.CityId.Value);
            }
            if (!string.IsNullOrEmpty(search.CityName))
            {
                query = query.Where(f => f.City.Name.Contains(search.CityName));
            }
            if (search.SubcategoryId.HasValue)
            {
                query = query.Where(f => f.SubcategoryId == search.SubcategoryId.Value);
            }
            if (search.UserIdAttended.HasValue)
            {
                var userId = search.UserIdAttended.Value;
                query = query.Where(f => _context.Tickets.Any(t => t.FestivalId == f.Id && t.UserId == userId));
            }
            if (search.OrganizerId.HasValue)
            {
                query = query.Where(f => f.OrganizerId == search.OrganizerId.Value);
            }
            if (search.StartDateFrom.HasValue)
            {
                query = query.Where(f => f.StartDate >= search.StartDateFrom.Value);
            }
            if (search.StartDateTo.HasValue)
            {
                query = query.Where(f => f.StartDate <= search.StartDateTo.Value);
            }
            if (search.IsActive.HasValue)
            {
                query = query.Where(f => f.IsActive == search.IsActive.Value);
            }

            return query
                .Include(f => f.City)
                    .ThenInclude(c => c.Country)
                .Include(f => f.Subcategory)
                    .ThenInclude(s => s.Category)
                .Include(f => f.Organizer)
                .Include(f => f.Assets);
        }

        // Train a simple recommender using Matrix Factorization on (User, Festival) implicit feedback
        public static void TrainRecommenderAtStartup(IServiceProvider serviceProvider)
        {
            lock (_mlLock)
            {
                if (_mlContext == null)
                {
                    _mlContext = new MLContext();
                }
                using var scope = serviceProvider.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<ManiFestDbContext>();

                // Build implicit feedback dataset combining tickets and positive reviews
                var positiveEntries =
                    db.Tickets.Select(t => new FeedbackEntry
                    {
                        UserId = (uint)t.UserId,
                        FestivalId = (uint)t.FestivalId,
                        Label = 1f
                    }).ToList();

                var positiveReviewEntries = db.Reviews
                    .Where(r => r.Rating >= 4)
                    .Select(r => new FeedbackEntry
                    {
                        UserId = (uint)r.UserId,
                        FestivalId = (uint)r.FestivalId,
                        Label = 1f
                    }).ToList();

                positiveEntries.AddRange(positiveReviewEntries);

                if (!positiveEntries.Any())
                {
                    _model = null;
                    return;
                }

                var trainData = _mlContext.Data.LoadFromEnumerable(positiveEntries);
                var options = new Microsoft.ML.Trainers.MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(FeedbackEntry.UserId),
                    MatrixRowIndexColumnName = nameof(FeedbackEntry.FestivalId),
                    LabelColumnName = nameof(FeedbackEntry.Label),
                    LossFunction = Microsoft.ML.Trainers.MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01,
                    Lambda = 0.025,
                    NumberOfIterations = 50,
                    C = 0.00001
                };

                var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                _model = estimator.Fit(trainData);
            }
        }

        public FestivalResponse RecommendForUser(int userId)
        {
            if (_model == null)
            {
                // Fallback: recommend an active upcoming festival the user hasn't attended, favor same subcategory/organizer
                return RecommendHeuristic(userId);
            }

            var predictionEngine = _mlContext.Model.CreatePredictionEngine<FeedbackEntry, FestivalScorePrediction>(_model);

            var attendedFestivalIds = _context.Tickets
                .Where(t => t.UserId == userId)
                .Select(t => t.FestivalId)
                .Distinct()
                .ToHashSet();

            var candidateFestivals = _context.Festivals
                .Include(f => f.City)
                    .ThenInclude(c => c.Country)
                .Include(f => f.Subcategory)
                    .ThenInclude(s => s.Category)
                .Include(f => f.Organizer)
                .Include(f => f.Assets)
                .Where(f => f.IsActive && f.EndDate >= DateTime.UtcNow && !attendedFestivalIds.Contains(f.Id))
                .ToList();

            if (!candidateFestivals.Any())
            {
                return RecommendHeuristic(userId);
            }

            // Score all candidates and pick best
            var scored = candidateFestivals
                .Select(f => new
                {
                    Festival = f,
                    Score = predictionEngine.Predict(new FeedbackEntry
                    {
                        UserId = (uint)userId,
                        FestivalId = (uint)f.Id
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .First().Festival;

            return MapToResponse(scored);
        }

        private FestivalResponse RecommendHeuristic(int userId)
        {
            var attendedFestivalIds = _context.Tickets
                .Where(t => t.UserId == userId)
                .Select(t => t.FestivalId)
                .Distinct()
                .ToHashSet();

            var likedSubcategoryIds = _context.Reviews
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .Select(r => r.Festival.SubcategoryId)
                .ToList();

            var attendedOrganizerIds = _context.Tickets
                .Where(t => t.UserId == userId)
                .Select(t => t.Festival.OrganizerId)
                .ToList();

            var candidate = _context.Festivals
                .Include(f => f.City)
                    .ThenInclude(c => c.Country)
                .Include(f => f.Subcategory)
                    .ThenInclude(s => s.Category)
                .Include(f => f.Organizer)
                .Include(f => f.Assets)
                .Where(f => f.IsActive && f.EndDate >= DateTime.UtcNow && !attendedFestivalIds.Contains(f.Id))
                .OrderByDescending(f => likedSubcategoryIds.Contains(f.SubcategoryId) ? 2 : 0)
                .ThenByDescending(f => attendedOrganizerIds.Contains(f.OrganizerId) ? 1 : 0)
                .ThenBy(f => f.StartDate)
                .FirstOrDefault();

            if (candidate == null) throw new InvalidOperationException("No suitable festival found for recommendation.");
            return MapToResponse(candidate);
        }

        private class FeedbackEntry
        {
            [KeyType(count: 100000)]
            public uint UserId { get; set; }
            [KeyType(count: 100000)]
            public uint FestivalId { get; set; }
            public float Label { get; set; }
        }

        private class FestivalScorePrediction
        {
            public float Score { get; set; }
        }
        public async Task<PagedResult<FestivalResponse>> GetWithoutAssetsAsync(FestivalSearchObject search)
        {
            var query = _context.Festivals.AsQueryable();

            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(f => f.Title.Contains(search.Title));
            }
            if (search.CityId.HasValue)
            {
                query = query.Where(f => f.CityId == search.CityId.Value);
            }
            if (!string.IsNullOrEmpty(search.CityName))
            {
                query = query.Where(f => f.City.Name.Contains(search.CityName));
            }
            if (search.SubcategoryId.HasValue)
            {
                query = query.Where(f => f.SubcategoryId == search.SubcategoryId.Value);
            }
            if (search.UserIdAttended.HasValue)
            {
                var userId = search.UserIdAttended.Value;
                query = query.Where(f => _context.Tickets.Any(t => t.FestivalId == f.Id && t.UserId == userId));
            }
            if (search.OrganizerId.HasValue)
            {
                query = query.Where(f => f.OrganizerId == search.OrganizerId.Value);
            }
            if (search.StartDateFrom.HasValue)
            {
                query = query.Where(f => f.StartDate >= search.StartDateFrom.Value);
            }
            if (search.StartDateTo.HasValue)
            {
                query = query.Where(f => f.StartDate <= search.StartDateTo.Value);
            }
            if (search.IsActive.HasValue)
            {
                query = query.Where(f => f.IsActive == search.IsActive.Value);
            }

            query = query
                .Include(f => f.City)
                    .ThenInclude(c => c.Country)
                .Include(f => f.Subcategory)
                    .ThenInclude(s => s.Category)
                .Include(f => f.Organizer);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var entities = await query.ToListAsync();
            var items = entities.Select(entity =>
            {
                var response = MapToResponse(entity);
                if (response != null)
                {
                    response.Assets = null;
                }
                return response;
            }).ToList();

            return new PagedResult<FestivalResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        public override async Task<FestivalResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Festivals
                .Include(f => f.City)
                    .ThenInclude(c => c.Country)
                .Include(f => f.Subcategory)
                    .ThenInclude(s => s.Category)
                .Include(f => f.Organizer)
                .Include(f => f.Assets)
                .FirstOrDefaultAsync(f => f.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Festival entity, FestivalUpsertRequest request)
        {
            ValidateDatesAndPrice(request);

            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
                throw new InvalidOperationException("The specified city does not exist.");

            if (!await _context.Subcategories.AnyAsync(s => s.Id == request.SubcategoryId))
                throw new InvalidOperationException("The specified subcategory does not exist.");

            if (!await _context.Set<Organizer>().AnyAsync(o => o.Id == request.OrganizerId))
                throw new InvalidOperationException("The specified organizer does not exist.");
        }

        protected override async Task AfterInsert(Festival entity, FestivalUpsertRequest request)
        {
            await SendFestivalNotification(entity, "Created");
            await base.AfterInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Festival entity, FestivalUpsertRequest request)
        {
            ValidateDatesAndPrice(request);

            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
                throw new InvalidOperationException("The specified city does not exist.");

            if (!await _context.Subcategories.AnyAsync(s => s.Id == request.SubcategoryId))
                throw new InvalidOperationException("The specified subcategory does not exist.");

            if (!await _context.Set<Organizer>().AnyAsync(o => o.Id == request.OrganizerId))
                throw new InvalidOperationException("The specified organizer does not exist.");
        }

        protected override async Task AfterUpdate(Festival entity, FestivalUpsertRequest request)
        {
            await SendFestivalNotification(entity, "Updated");
            await base.AfterUpdate(entity, request);
        }

        private static void ValidateDatesAndPrice(FestivalUpsertRequest request)
        {
            if (request.EndDate < request.StartDate)
                throw new InvalidOperationException("End date must be greater than or equal to start date.");
            if (request.BasePrice < 0)
                throw new InvalidOperationException("Base price must be a non-negative value.");
        }

        protected override Festival MapInsertToEntity(Festival entity, FestivalUpsertRequest request)
        {
            entity = base.MapInsertToEntity(entity, request);
            entity.CreatedAt = DateTime.Now;
            return entity;
        }

        protected override void MapUpdateToEntity(Festival entity, FestivalUpsertRequest request)
        {
            base.MapUpdateToEntity(entity, request);
        }

        private async Task SendFestivalNotification(Festival entity, string notificationType)
        {
            try
            {
                // Get all users with role "User" (roleId = 2)
                var userEmails = await _context.Users
                    .Where(u => u.UserRoles.Any(ur => ur.RoleId == 2) && u.IsActive)
                    .Select(u => u.Email)
                    .ToListAsync();

                if (!userEmails.Any())
                {
                    return; // No users to notify
                }

                // Load related entities for the festival
                var festivalWithRelations = await _context.Festivals
                    .Include(f => f.City)
                        .ThenInclude(c => c.Country)
                    .Include(f => f.Subcategory)
                        .ThenInclude(s => s.Category)
                    .Include(f => f.Organizer)
                    .FirstOrDefaultAsync(f => f.Id == entity.Id);

                if (festivalWithRelations == null)
                    return;

                // RabbitMQ connection configuration
                var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

                using var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

                // Create festival notification DTO
                var notificationDto = new FestivalNotificationDto
                {
                    Title = festivalWithRelations.Title,
                    StartDate = festivalWithRelations.StartDate,
                    EndDate = festivalWithRelations.EndDate,
                    BasePrice = festivalWithRelations.BasePrice,
                    Location = festivalWithRelations.Location,
                    CityName = festivalWithRelations.City?.Name ?? "Unknown",
                    SubcategoryName = festivalWithRelations.Subcategory?.Name ?? "Unknown",
                    OrganizerName = festivalWithRelations.Organizer?.Name ?? "Unknown",
                    NotificationType = notificationType,
                    UserEmails = userEmails
                };

                var festivalNotification = new FestivalNotification
                {
                    Festival = notificationDto
                };

                await bus.PubSub.PublishAsync(festivalNotification);
            }
            catch (Exception ex)
            {
                // Log the error but don't throw to avoid breaking the main operation
                // You might want to inject ILogger here for proper logging
                Console.WriteLine($"Failed to send festival notification: {ex.Message}");
            }
        }

        // Override MapToResponse to manually map nested properties
        protected override FestivalResponse MapToResponse(Festival entity)
        {
            var response = base.MapToResponse(entity);
            
            // Manually map nested properties that Mapster might not handle properly
            if (response != null)
            {
                response.CountryName = entity.City?.Country?.Name ?? string.Empty;
                response.CategoryName = entity.Subcategory?.Category?.Name ?? string.Empty;
                response.CountryFlag = entity.City?.Country?.Flag ?? null;
            }
            
            return response;
        }
    }
}
