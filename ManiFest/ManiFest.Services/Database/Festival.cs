using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManiFest.Services.Database
{
    public class Festival
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal BasePrice { get; set; }

        [MaxLength(100)]
        public string? Location { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public int CityId { get; set; }
        public City City { get; set; } = null!;

        public int SubcategoryId { get; set; }
        public Subcategory Subcategory { get; set; } = null!;

        public int OrganizerId { get; set; }
        public Organizer Organizer { get; set; } = null!;

        // Navigation property for assets/images
        public System.Collections.Generic.ICollection<Asset> Assets { get; set; } = new System.Collections.Generic.List<Asset>();
    }
}
