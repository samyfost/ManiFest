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
    public class SubcategoryService : BaseCRUDService<SubcategoryResponse, SubcategorySearchObject, Subcategory, SubcategoryUpsertRequest, SubcategoryUpsertRequest>, ISubcategoryService
    {
        public SubcategoryService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Subcategory> ApplyFilter(IQueryable<Subcategory> query, SubcategorySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }
            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }
            if (search.CategoryId.HasValue)
            {
                query = query.Where(x => x.CategoryId == search.CategoryId.Value);
            }
            return query.Include(x => x.Category);
        }

        protected override async Task BeforeInsert(Subcategory entity, SubcategoryUpsertRequest request)
        {
            if (await _context.Subcategories.AnyAsync(s => s.Name == request.Name && s.CategoryId == request.CategoryId))
            {
                throw new System.InvalidOperationException("A subcategory with this name already exists in this category.");
            }
            if (!await _context.Categories.AnyAsync(c => c.Id == request.CategoryId))
            {
                throw new System.InvalidOperationException("The specified category does not exist.");
            }
        }

        protected override async Task BeforeUpdate(Subcategory entity, SubcategoryUpsertRequest request)
        {
            if (await _context.Subcategories.AnyAsync(s => s.Name == request.Name && s.CategoryId == request.CategoryId && s.Id != entity.Id))
            {
                throw new System.InvalidOperationException("A subcategory with this name already exists in this category.");
            }
            if (!await _context.Categories.AnyAsync(c => c.Id == request.CategoryId))
            {
                throw new System.InvalidOperationException("The specified category does not exist.");
            }
        }
    }
}
