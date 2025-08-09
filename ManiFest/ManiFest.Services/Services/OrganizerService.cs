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
    public class OrganizerService : BaseCRUDService<OrganizerResponse, OrganizerSearchObject, Organizer, OrganizerUpsertRequest, OrganizerUpsertRequest>, IOrganizerService
    {
        public OrganizerService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Organizer> ApplyFilter(IQueryable<Organizer> query, OrganizerSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(o => o.Name.Contains(search.Name));
            }
            if (search.IsActive.HasValue)
            {
                query = query.Where(o => o.IsActive == search.IsActive.Value);
            }
            return query;
        }

        protected override async Task BeforeInsert(Organizer entity, OrganizerUpsertRequest request)
        {
            if (await _context.Set<Organizer>().AnyAsync(o => o.Name == request.Name))
            {
                throw new System.InvalidOperationException("An organizer with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Organizer entity, OrganizerUpsertRequest request)
        {
            if (await _context.Set<Organizer>().AnyAsync(o => o.Name == request.Name && o.Id != entity.Id))
            {
                throw new System.InvalidOperationException("An organizer with this name already exists.");
            }
        }
    }
}
