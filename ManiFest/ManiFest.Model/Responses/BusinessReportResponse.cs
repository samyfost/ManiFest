using System;
using System.Collections.Generic;

namespace ManiFest.Model.Responses
{
	public class BusinessReportResponse
	{
		public List<FestivalRevenueResponse> TopGrossingFestivals { get; set; } = new List<FestivalRevenueResponse>();
		public decimal TotalRevenueThisYear { get; set; }
		public int TotalTicketsSoldThisYear { get; set; }
		public UserResponse? UserWithMostTickets { get; set; }
		public int? UserWithMostTicketsCount { get; set; }
		public List<FestivalRatingResponse> TopFestivalsByAverageRating { get; set; } = new List<FestivalRatingResponse>();
	}

	public class FestivalRevenueResponse
	{
		public int FestivalId { get; set; }
		public string Title { get; set; } = string.Empty;
		public decimal TotalRevenue { get; set; }
	}

	public class FestivalRatingResponse
	{
		public int FestivalId { get; set; }
		public string Title { get; set; } = string.Empty;
		public double AverageRating { get; set; }
		public int ReviewCount { get; set; }
	}
}


