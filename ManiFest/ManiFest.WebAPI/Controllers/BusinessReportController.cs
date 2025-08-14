using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using ManiFest.Model.Responses;
using ManiFest.Services.Interfaces;

namespace ManiFest.WebAPI.Controllers
{
	[ApiController]
	[Route("[controller]")]
	public class BusinessReportController : ControllerBase
	{
		private readonly IBusinessReportService _businessReportService;
		public BusinessReportController(IBusinessReportService businessReportService)
		{
			_businessReportService = businessReportService;
		}

		[HttpGet]
		public async Task<ActionResult<BusinessReportResponse>> Get()
		{
			var report = await _businessReportService.GetBusinessReportAsync();
			return Ok(report);
		}
	}
}


