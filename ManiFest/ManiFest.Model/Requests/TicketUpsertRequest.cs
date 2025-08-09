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

        // Optional for creation: allow client to provide their own code; otherwise server generates
        [MaxLength(100)]
        public string? GeneratedCode { get; set; }
    }
}
