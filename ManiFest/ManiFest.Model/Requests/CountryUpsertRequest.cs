using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class CountryUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
    }
}
