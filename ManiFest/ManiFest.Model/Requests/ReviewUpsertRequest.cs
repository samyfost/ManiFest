using System.ComponentModel.DataAnnotations;

namespace ManiFest.Model.Requests
{
    public class ReviewUpsertRequest
    {
        [Required]
        [Range(1,5)]
        public int Rating { get; set; }

        [MaxLength(1000)]
        public string? Comment { get; set; }

        [Required]
        public int FestivalId { get; set; }

        [Required]
        public int UserId { get; set; }
    }
}
