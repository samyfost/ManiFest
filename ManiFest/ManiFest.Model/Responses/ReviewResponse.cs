using System;

namespace ManiFest.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
        public byte[]? FestivalLogo { get; set; }

        public int FestivalId { get; set; }
        public string FestivalTitle { get; set; } = string.Empty;

        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
    }
}
