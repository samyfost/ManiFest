namespace ManiFest.Model.Responses
{
    public class OrganizerResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? ContactInfo { get; set; }
        public bool IsActive { get; set; }
    }
}
