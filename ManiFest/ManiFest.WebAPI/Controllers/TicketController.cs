using ManiFest.Model.Requests;
using ManiFest.Model.Responses;
using ManiFest.Model.SearchObjects;
using ManiFest.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ManiFest.WebAPI.Controllers
{
    public class TicketController : BaseCRUDController<TicketResponse, TicketSearchObject, TicketUpsertRequest, TicketUpsertRequest>
    {
        private readonly ITicketService _ticketService;
        public TicketController(ITicketService service) : base(service)
        {
            _ticketService = service;
        }

        [HttpPost("redeem")]
        public async Task<ActionResult<TicketResponse>> Redeem([FromBody] string qrCodeData)
        {
            var ticket = await _ticketService.RedeemAsync(qrCodeData);
            if (ticket == null)
                return NotFound();
            return Ok(ticket);
        }

    
    }
}
