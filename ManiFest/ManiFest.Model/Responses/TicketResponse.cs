using System;

namespace ManiFest.Model.Responses
{
    public class TicketResponse
    {
        public int Id { get; set; }
        public int FestivalId { get; set; }
        public string FestivalTitle { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string UserFullName { get; set; } = string.Empty;
        public int TicketTypeId { get; set; }
        public string TicketTypeName { get; set; } = string.Empty;
        public decimal FinalPrice { get; set; }
        public string GeneratedCode { get; set; } = string.Empty;
        public bool IsRedeemed { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? RedeemedAt { get; set; }
    }
}
