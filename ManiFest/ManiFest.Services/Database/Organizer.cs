using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ManiFest.Services.Database
{
    public class Organizer
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? ContactInfo { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<Festival> Festivals { get; set; } = new List<Festival>();
    }
}
