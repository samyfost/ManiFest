using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ManiFest.WebAPI.Controllers
{
    public class CountryController : BaseCRUDController<CountryResponse, CountrySearchObject, CountryUpsertRequest, CountryUpsertRequest>
    {
        public CountryController(ICountryService service) : base(service)
        {
        }
    }
}
