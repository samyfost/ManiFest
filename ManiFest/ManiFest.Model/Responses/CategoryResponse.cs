using System.Collections.Generic;

namespace ManiFest.Model.Responses
{
    public class CategoryResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public List<SubcategoryResponse> Subcategories { get; set; } = new List<SubcategoryResponse>();
    }
}
