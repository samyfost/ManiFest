using System;
using System.Collections.Generic;

namespace ManiFest.Model.Responses
{
    public class FestivalResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;

        public byte[]? Logo { get; set; }
        public byte[]? CountryFlag { get; set; }

        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal BasePrice { get; set; }
        public string? Location { get; set; }
        public bool IsActive { get; set; }

        public int CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public string CountryName { get; set; } = string.Empty;


        public int SubcategoryId { get; set; }
        public string SubcategoryName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;

        public int OrganizerId { get; set; }
        public string OrganizerName { get; set; } = string.Empty;

        public List<AssetResponse> Assets { get; set; } = new List<AssetResponse>();
    }
}
