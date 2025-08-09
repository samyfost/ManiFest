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

namespace ManiFest.Services.Services
{
    public class FestivalService : BaseCRUDService<FestivalResponse, FestivalSearchObject, Festival, FestivalUpsertRequest, FestivalUpsertRequest>, IFestivalService
    {
        public FestivalService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
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
            if (search.SubcategoryId.HasValue)
            {
                query = query.Where(f => f.SubcategoryId == search.SubcategoryId.Value);
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
                .Include(f => f.Subcategory)
                .Include(f => f.Organizer)
                .Include(f => f.Assets);
        }

        public override async Task<FestivalResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Festivals
                .Include(f => f.City)
                .Include(f => f.Subcategory)
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
            entity.CreatedAt = DateTime.UtcNow;
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
                    .Include(f => f.Subcategory)
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

        // Use base mapping via Mapster to map entity to response
    }
}
