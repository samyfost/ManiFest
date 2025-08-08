using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ManiFest.WebAPI.Controllers
{
    public class SubcategoryController : BaseCRUDController<SubcategoryResponse, SubcategorySearchObject, SubcategoryUpsertRequest, SubcategoryUpsertRequest>
    {
        public SubcategoryController(ISubcategoryService service) : base(service)
        {
        }
    }
}
