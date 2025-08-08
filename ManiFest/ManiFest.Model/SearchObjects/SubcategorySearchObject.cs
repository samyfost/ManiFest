namespace ManiFest.Model.SearchObjects
{
    public class SubcategorySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public bool? IsActive { get; set; }
        public int? CategoryId { get; set; }
    }
}
