using System;

namespace ManiFest.Model.SearchObjects
{
    public class FestivalSearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public int? CityId { get; set; }
        public string? CityName { get; set; }
        public int? SubcategoryId { get; set; }
        public int? OrganizerId { get; set; }
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
        public bool? IsActive { get; set; }
    }
}
