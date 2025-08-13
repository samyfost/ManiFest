using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Database;
using ManiFest.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace ManiFest.Services.Services
{
    public class TicketService : BaseCRUDService<TicketResponse, TicketSearchObject, Ticket, TicketUpsertRequest, TicketUpsertRequest>, ITicketService
    {
        public TicketService(ManiFestDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Ticket> ApplyFilter(IQueryable<Ticket> query, TicketSearchObject search)
        {
            if (search.FestivalId.HasValue)
                query = query.Where(t => t.FestivalId == search.FestivalId.Value);
            if (search.UserId.HasValue)
                query = query.Where(t => t.UserId == search.UserId.Value);
            if (!string.IsNullOrWhiteSpace(search.UserFullName))
                query = query.Where(t => (t.User.FirstName + " " + t.User.LastName).Contains(search.UserFullName));
            if (!string.IsNullOrWhiteSpace(search.FestivalTitle))
                query = query.Where(t => t.Festival.Title.Contains(search.FestivalTitle));
            if (search.TicketTypeId.HasValue)
                query = query.Where(t => t.TicketTypeId == search.TicketTypeId.Value);
            if (search.IsRedeemed.HasValue)
                query = query.Where(t => t.IsRedeemed == search.IsRedeemed.Value);
            if (!string.IsNullOrEmpty(search.Code))
                query = query.Where(t => t.GeneratedCode.Contains(search.Code));

            return query
                .Include(t => t.Festival)
                .Include(t => t.TicketType)
                .Include(t => t.User);
        }

        protected override async Task BeforeInsert(Ticket entity, TicketUpsertRequest request)
        {
            var festival = await _context.Festivals.FindAsync(request.FestivalId)
                ?? throw new InvalidOperationException("Festival does not exist.");

            var user = await _context.Users.FindAsync(request.UserId)
                ?? throw new InvalidOperationException("User does not exist.");

            var ticketType = await _context.TicketTypes.FindAsync(request.TicketTypeId)
                ?? throw new InvalidOperationException("Ticket type does not exist.");

            var finalPrice = Math.Round(festival.BasePrice * (ticketType.PriceMultiplier <= 0 ? 1.0m : ticketType.PriceMultiplier), 2);
            entity.FinalPrice = finalPrice;

            entity.GeneratedCode = string.IsNullOrWhiteSpace(request.GeneratedCode)
                ? GenerateUniqueCode(request.FestivalId, request.UserId, ticketType.Name)
                : request.GeneratedCode!;
        }

        protected override async Task BeforeUpdate(Ticket entity, TicketUpsertRequest request)
        {
            // For safety, prevent changing price and user via Update through Upsert; normally we would have a dedicated update DTO
            // Recalculate price if ticket type changed
            if (entity.TicketTypeId != request.TicketTypeId)
            {
                var festival = await _context.Festivals.FindAsync(request.FestivalId)
                    ?? throw new InvalidOperationException("Festival does not exist.");
                var ticketType = await _context.TicketTypes.FindAsync(request.TicketTypeId)
                    ?? throw new InvalidOperationException("Ticket type does not exist.");
                entity.FinalPrice = Math.Round(festival.BasePrice * (ticketType.PriceMultiplier <= 0 ? 1.0m : ticketType.PriceMultiplier), 2);
            }
        }

        public async Task<TicketResponse?> RedeemAsync(string generatedCode)
        {
            var ticket = await _context.Tickets.FirstOrDefaultAsync(t => t.GeneratedCode == generatedCode);
            if (ticket == null)
                return null;
            if (ticket.IsRedeemed)
                throw new InvalidOperationException("Ticket already redeemed.");

            ticket.IsRedeemed = true;
            ticket.RedeemedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return MapToResponse(ticket);
        }

        protected override TicketResponse MapToResponse(Ticket entity)
        {
            var response = base.MapToResponse(entity);
            
            // Manually map nested properties that Mapster might not handle properly
            if (response != null)
            {
                response.FestivalTitle = entity.Festival?.Title ?? string.Empty;
                response.UserFullName = entity.User != null ? $"{entity.User.FirstName} {entity.User.LastName}" : string.Empty;
                response.Username = entity.User?.Username ?? string.Empty;
                response.TicketTypeName = entity.TicketType?.Name ?? string.Empty;
            }
            
            return response;
        }

        private static string GenerateUniqueCode(int festivalId, int userId, string ticketTypeName)
        {
            using var sha256 = SHA256.Create();
            var raw = $"{festivalId}:{userId}:{ticketTypeName}:{Guid.NewGuid()}";
            var hash = sha256.ComputeHash(Encoding.UTF8.GetBytes(raw));

            // Base64 string then filter to uppercase letters and numbers only
            var base64 = Convert.ToBase64String(hash);
            var cleaned = new string(base64.Where(ch => char.IsLetterOrDigit(ch)).ToArray()).ToUpperInvariant();

            // Ensure we have enough characters
            if (cleaned.Length < 6)
            {
                cleaned += Guid.NewGuid().ToString("N").ToUpperInvariant();
            }

            var part1 = cleaned.Substring(0, 3);
            var part2 = cleaned.Substring(3, 3);

            var suffix = (ticketTypeName ?? string.Empty).Trim();
            suffix = suffix.Length >= 3 ? suffix.Substring(0, 3).ToUpperInvariant() : suffix.ToUpperInvariant().PadRight(3, 'X');

            return $"{part1}-{part2}-{suffix}";
        }
    }
}
