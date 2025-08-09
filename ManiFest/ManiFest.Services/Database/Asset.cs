using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManiFest.Services.Database
{
    public class Asset
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string FileName { get; set; } = string.Empty;

        [Required]
        public string ContentType { get; set; } = string.Empty;

        [Required]
        public string Base64Content { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public int FestivalId { get; set; }
        [ForeignKey("FestivalId")]
        public Festival Festival { get; set; } = null!;
    }
}
