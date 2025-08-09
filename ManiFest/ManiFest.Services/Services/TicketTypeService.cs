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
    public class TicketTypeService : BaseCRUDService<TicketTypeResponse, TicketTypeSearchObject, TicketType, TicketTypeUpsertRequest, TicketTypeUpsertRequest>, ITicketTypeService
    {
        public TicketTypeService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<TicketType> ApplyFilter(IQueryable<TicketType> query, TicketTypeSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(tt => tt.Name.Contains(search.Name));
            }
            if (search.IsActive.HasValue)
            {
                query = query.Where(tt => tt.IsActive == search.IsActive.Value);
            }
            return query;
        }

        protected override async Task BeforeInsert(TicketType entity, TicketTypeUpsertRequest request)
        {
            if (await _context.TicketTypes.AnyAsync(tt => tt.Name == request.Name))
                throw new System.InvalidOperationException("A ticket type with this name already exists.");
        }

        protected override async Task BeforeUpdate(TicketType entity, TicketTypeUpsertRequest request)
        {
            if (await _context.TicketTypes.AnyAsync(tt => tt.Name == request.Name && tt.Id != entity.Id))
                throw new System.InvalidOperationException("A ticket type with this name already exists.");
        }
    }
}
