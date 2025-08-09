using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;

namespace ManiFest.WebAPI.Controllers
{
    public class TicketTypeController : BaseCRUDController<TicketTypeResponse, TicketTypeSearchObject, TicketTypeUpsertRequest, TicketTypeUpsertRequest>
    {
        public TicketTypeController(ITicketTypeService service) : base(service)
        {
        }
    }
}
