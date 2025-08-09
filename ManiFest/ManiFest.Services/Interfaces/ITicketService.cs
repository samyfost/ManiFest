using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using System.Threading.Tasks;

namespace ManiFest.Services.Interfaces
{
    public interface ITicketService : ICRUDService<TicketResponse, TicketSearchObject, TicketUpsertRequest, TicketUpsertRequest>
    {
        Task<TicketResponse?> RedeemAsync(string generatedCode);
    }
}
