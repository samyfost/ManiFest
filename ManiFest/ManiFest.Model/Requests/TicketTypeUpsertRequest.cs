using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class TicketTypeUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? Description { get; set; }

        [Range(0.1, 10)]
        public decimal PriceMultiplier { get; set; } = 1.0m;

        public bool IsActive { get; set; } = true;
    }
}
