using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ManiFest.WebAPI.Controllers
{
    public class CategoryController : BaseCRUDController<CategoryResponse, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {
        public CategoryController(ICategoryService service) : base(service)
        {
        }
    }
}
