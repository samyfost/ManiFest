using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;

namespace ManiFest.WebAPI.Controllers
{
    public class AssetController : BaseCRUDController<AssetResponse, AssetSearchObject, AssetUpsertRequest, AssetUpsertRequest>
    {
        public AssetController(IAssetService service) : base(service)
        {
        }
    }
}
