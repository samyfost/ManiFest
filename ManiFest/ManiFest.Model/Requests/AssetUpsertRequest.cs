using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class AssetUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string FileName { get; set; } = string.Empty;

        [Required]
        public string ContentType { get; set; } = string.Empty;

        [Required]
        public string Base64Content { get; set; } = string.Empty;

        [Required]
        public int FestivalId { get; set; }
    }
}
