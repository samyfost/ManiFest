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

        [HttpGet("recommend/{userId}")]
        public ActionResult<FestivalResponse> Recommend(int userId)
        {
            var typedService = (IFestivalService)_crudService;
            try
            {
                var result = typedService.RecommendForUser(userId);
                if (result == null)
                    return NotFound();
                return Ok(result);
            }
            catch
            {
                return NotFound();
            }
        }
    }
}
