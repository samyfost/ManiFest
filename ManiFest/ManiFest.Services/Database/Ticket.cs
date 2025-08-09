using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManiFest.Services.Database
{
    public class Ticket
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int FestivalId { get; set; }
        [ForeignKey("FestivalId")]
        public Festival Festival { get; set; } = null!;

        [Required]
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [Required]
        public int TicketTypeId { get; set; }
        [ForeignKey("TicketTypeId")]
        public TicketType TicketType { get; set; } = null!;

        [Column(TypeName = "decimal(18,2)")]
        public decimal FinalPrice { get; set; }

        [Required]
        [MaxLength(100)]
        public string GeneratedCode { get; set; } = string.Empty;

        public bool IsRedeemed { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? RedeemedAt { get; set; }
    }
}
