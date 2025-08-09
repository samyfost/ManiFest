using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;

namespace ManiFest.Services.Interfaces
{
    public interface ITicketTypeService : ICRUDService<TicketTypeResponse, TicketTypeSearchObject, TicketTypeUpsertRequest, TicketTypeUpsertRequest>
    {
    }
}
