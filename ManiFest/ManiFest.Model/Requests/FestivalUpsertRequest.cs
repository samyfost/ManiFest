using System;
using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class FestivalUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        [Range(0, double.MaxValue)]
        public decimal BasePrice { get; set; }

        [MaxLength(100)]
        public string? Location { get; set; }

        [Required]
        public int CityId { get; set; }

        [Required]
        public int SubcategoryId { get; set; }

        [Required]
        public int OrganizerId { get; set; }

        public bool IsActive { get; set; } = true;
    }
}
