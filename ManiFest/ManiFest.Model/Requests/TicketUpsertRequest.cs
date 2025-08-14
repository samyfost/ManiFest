using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class TicketUpsertRequest
    {
        [Required]
        public int FestivalId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public int TicketTypeId { get; set; }

        // Optional for creation: allow client to provide their own QR code data; otherwise server generates
        [MaxLength(500)]
        public string? QrCodeData { get; set; }

        [MaxLength(100)]
        public string? TextCode { get; set; }
    }
}
