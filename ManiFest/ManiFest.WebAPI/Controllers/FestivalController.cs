using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;

namespace ManiFest.WebAPI.Controllers
{
    public class FestivalController : BaseCRUDController<FestivalResponse, FestivalSearchObject, FestivalUpsertRequest, FestivalUpsertRequest>
    {
        public FestivalController(IFestivalService service) : base(service)
        {
        }
    }
}
