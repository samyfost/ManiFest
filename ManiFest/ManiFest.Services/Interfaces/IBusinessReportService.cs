using System.Threading.Tasks;
using ManiFest.Model.Responses;

namespace ManiFest.Services.Interfaces
{
	public interface IBusinessReportService
	{
		Task<BusinessReportResponse> GetBusinessReportAsync();
	}
}


