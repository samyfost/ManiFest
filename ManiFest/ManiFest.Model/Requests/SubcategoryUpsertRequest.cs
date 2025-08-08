using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class SubcategoryUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Description { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;

        [Required]
        public int CategoryId { get; set; }
    }
}
