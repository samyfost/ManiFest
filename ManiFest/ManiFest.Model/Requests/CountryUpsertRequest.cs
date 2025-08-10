using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class CountryUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
        
        public byte[]? Flag { get; set; } // base64 encoded string from API
    }
}
