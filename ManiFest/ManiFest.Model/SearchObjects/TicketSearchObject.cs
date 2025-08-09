namespace ManiFest.Model.SearchObjects
{
    public class TicketSearchObject : BaseSearchObject
    {
        public int? FestivalId { get; set; }
        public int? UserId { get; set; }
        public int? TicketTypeId { get; set; }
        public bool? IsRedeemed { get; set; }
        public string? Code { get; set; }
    }
}
