using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;
using ManiFest.Model;
using Microsoft.AspNetCore.Mvc;

namespace ManiFest.WebAPI.Controllers
{
    public class FestivalController : BaseCRUDController<FestivalResponse, FestivalSearchObject, FestivalUpsertRequest, FestivalUpsertRequest>
    {
        public FestivalController(IFestivalService service) : base(service)
        {
        }

        [HttpGet("without-assets")]
        public async Task<PagedResult<FestivalResponse>> GetWithoutAssets([FromQuery] FestivalSearchObject? search = null)
        {
            var typedService = (IFestivalService)_crudService;
            return await typedService.GetWithoutAssetsAsync(search ?? new FestivalSearchObject());
        }
    }
}
