using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Database;
using ManiFest.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace ManiFest.Services.Services
{
    public class CategoryService : BaseCRUDService<CategoryResponse, CategorySearchObject, Category, CategoryUpsertRequest, CategoryUpsertRequest>, ICategoryService
    {
        public CategoryService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Category> ApplyFilter(IQueryable<Category> query, CategorySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }
            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }
            return query.Include(x => x.Subcategories);
        }

        protected override async Task BeforeInsert(Category entity, CategoryUpsertRequest request)
        {
            if (await _context.Categories.AnyAsync(c => c.Name == request.Name))
            {
                throw new System.InvalidOperationException("A category with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Category entity, CategoryUpsertRequest request)
        {
            if (await _context.Categories.AnyAsync(c => c.Name == request.Name && c.Id != entity.Id))
            {
                throw new System.InvalidOperationException("A category with this name already exists.");
            }
        }
    }
}
