using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;

namespace ManiFest.Services.Interfaces
{
    public interface IFestivalService : ICRUDService<FestivalResponse, FestivalSearchObject, FestivalUpsertRequest, FestivalUpsertRequest>
    {
    }
}
