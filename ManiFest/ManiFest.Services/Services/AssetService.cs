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
    public class AssetService : BaseCRUDService<AssetResponse, AssetSearchObject, Asset, AssetUpsertRequest, AssetUpsertRequest>, IAssetService
    {
        public AssetService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Asset> ApplyFilter(IQueryable<Asset> query, AssetSearchObject search)
        {
            if (search.FestivalId.HasValue)
            {
                query = query.Where(a => a.FestivalId == search.FestivalId.Value);
            }
            if (!string.IsNullOrEmpty(search.FileName))
            {
                query = query.Where(a => a.FileName.Contains(search.FileName));
            }
            if (!string.IsNullOrEmpty(search.ContentType))
            {
                query = query.Where(a => a.ContentType.Contains(search.ContentType));
            }
            return query.Include(a => a.Festival);
        }

        protected override async Task BeforeInsert(Asset entity, AssetUpsertRequest request)
        {
            if (!await _context.Festivals.AnyAsync(f => f.Id == request.FestivalId))
            {
                throw new System.InvalidOperationException("The specified festival does not exist.");
            }
        }

        protected override async Task BeforeUpdate(Asset entity, AssetUpsertRequest request)
        {
            if (!await _context.Festivals.AnyAsync(f => f.Id == request.FestivalId))
            {
                throw new System.InvalidOperationException("The specified festival does not exist.");
            }
        }
    }
}
