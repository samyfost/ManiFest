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
    public class CityService : BaseCRUDService<CityResponse, CitySearchObject, City, CityUpsertRequest, CityUpsertRequest>, ICityService
    {
        public CityService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (search.CountryId.HasValue)
            {
                query = query.Where(x => x.CountryId == search.CountryId.Value);
            }

            return query.Include(x => x.Country);
        }

        protected override async Task BeforeInsert(City entity, CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name && c.CountryId == request.CountryId))
            {
                throw new InvalidOperationException("A city with this name already exists in this country.");
            }

            if (!await _context.Countries.AnyAsync(c => c.Id == request.CountryId))
            {
                throw new InvalidOperationException("The specified country does not exist.");
            }
        }

        protected override async Task BeforeUpdate(City entity, CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name && c.CountryId == request.CountryId && c.Id != entity.Id))
            {
                throw new InvalidOperationException("A city with this name already exists in this country.");
            }

            if (!await _context.Countries.AnyAsync(c => c.Id == request.CountryId))
            {
                throw new InvalidOperationException("The specified country does not exist.");
            }
        }
    }
} 