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
                .Include(f => f.Organizer);
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

        // Use base mapping via Mapster to map entity to response
    }
}
