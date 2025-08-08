using System;
using System.ComponentModel.DataAnnotations;

namespace ManiFest.Services.Database
{
    public class Subcategory
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Description { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Foreign key
        public int CategoryId { get; set; }
        // Navigation property
        public Category Category { get; set; } = null!;
    }
}
