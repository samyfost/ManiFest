using System;
using System.ComponentModel.DataAnnotations;

namespace ManiFest.Services.Database
{
    public class TicketType
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? Description { get; set; }

        // Multiplier applied to Festival.BasePrice, e.g., 1.0 standard, 1.5 VIP
        public decimal PriceMultiplier { get; set; } = 1.0m;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
