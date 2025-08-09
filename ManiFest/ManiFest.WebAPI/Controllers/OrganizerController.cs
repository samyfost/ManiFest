using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;

namespace ManiFest.WebAPI.Controllers
{
    public class OrganizerController : BaseCRUDController<OrganizerResponse, OrganizerSearchObject, OrganizerUpsertRequest, OrganizerUpsertRequest>
    {
        public OrganizerController(IOrganizerService service) : base(service)
        {
        }
    }
}
