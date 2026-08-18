namespace Inventory.Application.DTOs.Products
{
    public class UpdateProductDto
    {
        public string SKU { get; set; } = string.Empty;
        public string? Barcode { get; set; }
        public string Name { get; set; } = string.Empty;
        public int? CategoryId { get; set; }
        public decimal BasePrice { get; set; }
        public string Unit { get; set; } = string.Empty;
        public int ReorderLevel { get; set; }
    }
}
