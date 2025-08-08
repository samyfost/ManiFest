using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ManiFest.Services.Database
{
    public class Category
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

        // Navigation property
        public ICollection<Subcategory> Subcategories { get; set; } = new List<Subcategory>();
    }
}
