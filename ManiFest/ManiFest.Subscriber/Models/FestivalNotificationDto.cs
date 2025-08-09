using System;
using System.Collections.Generic;

namespace ManiFest.Subscriber.Models
{
    public class FestivalNotificationDto
    {
        public string Title { get; set; } = null!;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal BasePrice { get; set; }
        public string Location { get; set; } = null!;
        public string CityName { get; set; } = null!;
        public string SubcategoryName { get; set; } = null!;
        public string OrganizerName { get; set; } = null!;
        public string NotificationType { get; set; } = null!; // "Created" or "Updated"
        public List<string> UserEmails { get; set; } = new List<string>();
    }
}
