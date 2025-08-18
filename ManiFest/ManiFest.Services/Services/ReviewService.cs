using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Database;
using ManiFest.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace ManiFest.Services.Services
{
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewUpsertRequest, ReviewUpsertRequest>, IReviewService
    {
        public ReviewService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            if (search.FestivalId.HasValue)
            {
                query = query.Where(r => r.FestivalId == search.FestivalId.Value);
            }
            if (!string.IsNullOrWhiteSpace(search.FestivalTitle))
            {
                query = query.Where(r => r.Festival.Title.Contains(search.FestivalTitle));
            }
            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }
            if (!string.IsNullOrWhiteSpace(search.UserFullName))
            {
                query = query.Where(r => (r.User.FirstName + " " + r.User.LastName).Contains(search.UserFullName));
            }
            if (search.MinRating.HasValue)
            {
                query = query.Where(r => r.Rating >= search.MinRating.Value);
            }
            if (search.MaxRating.HasValue)
            {
                query = query.Where(r => r.Rating <= search.MaxRating.Value);
            }
            return query.Include(r => r.Festival).Include(r => r.User);
        }

        protected override ReviewResponse MapToResponse(Review entity)
        {
            return new ReviewResponse
            {
                Id = entity.Id,
                Rating = entity.Rating,
                Comment = entity.Comment,
                CreatedAt = entity.CreatedAt,
                FestivalId = entity.FestivalId,
                FestivalTitle = entity.Festival?.Title ?? string.Empty,
                UserId = entity.UserId,
                UserFullName = entity.User != null ? $"{entity.User.FirstName} {entity.User.LastName}" : string.Empty,
                Username = entity.User?.Username ?? string.Empty,
                FestivalLogo = entity.Festival?.Logo,
            };
        }

        protected override async Task BeforeInsert(Review entity, ReviewUpsertRequest request)
        {
            if (!await _context.Festivals.AnyAsync(f => f.Id == request.FestivalId))
                throw new System.InvalidOperationException("The specified festival does not exist.");
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
                throw new System.InvalidOperationException("The specified user does not exist.");
            if (request.Rating < 1 || request.Rating > 5)
                throw new System.InvalidOperationException("Rating must be between 1 and 5.");
        }

        protected override async Task BeforeUpdate(Review entity, ReviewUpsertRequest request)
        {
            if (!await _context.Festivals.AnyAsync(f => f.Id == request.FestivalId))
                throw new System.InvalidOperationException("The specified festival does not exist.");
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
                throw new System.InvalidOperationException("The specified user does not exist.");
            if (request.Rating < 1 || request.Rating > 5)
                throw new System.InvalidOperationException("Rating must be between 1 and 5.");
        }
    }
}
