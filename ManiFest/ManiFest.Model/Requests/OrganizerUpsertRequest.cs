using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class OrganizerUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? ContactInfo { get; set; }

        public bool IsActive { get; set; } = true;
    }
}
