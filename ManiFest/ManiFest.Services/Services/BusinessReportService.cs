using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using ManiFest.Model.Responses;
using ManiFest.Services.Database;
using ManiFest.Services.Interfaces;

namespace ManiFest.Services.Services
{
	public class BusinessReportService : IBusinessReportService
	{
		private readonly ManiFestDbContext _context;
		public BusinessReportService(ManiFestDbContext context)
		{
			_context = context;
		}

		public async Task<BusinessReportResponse> GetBusinessReportAsync()
		{
			var currentYear = DateTime.UtcNow.Year;

			// Top 3 highest grossing festivals (by ticket revenue)
			var topGrossingFestivals = await _context.Tickets
				.GroupBy(t => t.FestivalId)
				.Select(g => new { FestivalId = g.Key, TotalRevenue = g.Sum(t => t.FinalPrice) })
				.OrderByDescending(x => x.TotalRevenue)
				.Take(3)
				.Join(_context.Festivals,
					g => g.FestivalId,
					f => f.Id,
					(g, f) => new FestivalRevenueResponse
					{
						FestivalId = f.Id,
						Title = f.Title,
						TotalRevenue = g.TotalRevenue
					})
				.ToListAsync();

			// Total revenue this year (all festivals)
			var totalRevenueThisYear = await _context.Tickets
				.Where(t => t.CreatedAt.Year == currentYear)
				.SumAsync(t => (decimal?)t.FinalPrice) ?? 0m;

			// Total tickets sold this year
			var totalTicketsSoldThisYear = await _context.Tickets
				.Where(t => t.CreatedAt.Year == currentYear)
				.CountAsync();

			// User with most bought tickets
			var userTicketCounts = await _context.Tickets
				.GroupBy(t => t.UserId)
				.Select(g => new { UserId = g.Key, TicketCount = g.Count() })
				.OrderByDescending(x => x.TicketCount)
				.FirstOrDefaultAsync();

			UserResponse? userWithMostTickets = null;
			int? userWithMostTicketsCount = null;
			if (userTicketCounts != null)
			{
				var user = await _context.Users
					.Include(u => u.Gender)
					.Include(u => u.City)
					.FirstOrDefaultAsync(u => u.Id == userTicketCounts.UserId);
				if (user != null)
				{
					userWithMostTickets = new UserResponse
					{
						Id = user.Id,
						FirstName = user.FirstName,
						LastName = user.LastName,
						Email = user.Email,
						Username = user.Username,
						Picture = user.Picture,
						IsActive = user.IsActive,
						CreatedAt = user.CreatedAt,
						LastLoginAt = user.LastLoginAt,
						PhoneNumber = user.PhoneNumber,
						GenderId = user.GenderId,
						GenderName = user.Gender.Name,
						CityId = user.CityId,
						CityName = user.City.Name,
						Roles = new List<RoleResponse>()
					};
					userWithMostTicketsCount = userTicketCounts.TicketCount;
				}
			}

			// Top festivals by average rating (take 3)
			var topFestivalsByAverageRating = await _context.Reviews
				.GroupBy(r => r.FestivalId)
				.Select(g => new { FestivalId = g.Key, AverageRating = g.Average(r => (double)r.Rating), ReviewCount = g.Count() })
				.OrderByDescending(x => x.AverageRating)
				.ThenByDescending(x => x.ReviewCount)
				.Take(3)
				.Join(_context.Festivals,
					g => g.FestivalId,
					f => f.Id,
					(g, f) => new FestivalRatingResponse
					{
						FestivalId = f.Id,
						Title = f.Title,
						AverageRating = Math.Round(g.AverageRating, 2),
						ReviewCount = g.ReviewCount
					})
				.ToListAsync();

			return new BusinessReportResponse
			{
				TopGrossingFestivals = topGrossingFestivals,
				TotalRevenueThisYear = totalRevenueThisYear,
				TotalTicketsSoldThisYear = totalTicketsSoldThisYear,
				UserWithMostTickets = userWithMostTickets,
				UserWithMostTicketsCount = userWithMostTicketsCount,
				TopFestivalsByAverageRating = topFestivalsByAverageRating
			};
		}
	}
}


