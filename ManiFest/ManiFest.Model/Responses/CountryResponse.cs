namespace ManiFest.Model.Responses
{
    public class CountryResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public byte[]? Flag { get; set; } 
    }
}
