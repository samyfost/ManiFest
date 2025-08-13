namespace ManiFest.Model.SearchObjects
{
    public class TicketSearchObject : BaseSearchObject
    {
        public int? FestivalId { get; set; }
        public string? FestivalTitle { get; set; }
        public int? UserId { get; set; }
        public string? UserFullName { get; set; }
        public int? TicketTypeId { get; set; }
        public bool? IsRedeemed { get; set; }
        public string? Code { get; set; }
    }
}
