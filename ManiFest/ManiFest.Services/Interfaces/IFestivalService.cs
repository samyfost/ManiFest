using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Model;
using System.Threading.Tasks;

namespace ManiFest.Services.Interfaces
{
    public interface IFestivalService : ICRUDService<FestivalResponse, FestivalSearchObject, FestivalUpsertRequest, FestivalUpsertRequest>
    {
        Task<PagedResult<FestivalResponse>> GetWithoutAssetsAsync(FestivalSearchObject search);
    }
}
