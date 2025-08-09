namespace ManiFest.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? FestivalId { get; set; }
        public int? UserId { get; set; }
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
    }
}
