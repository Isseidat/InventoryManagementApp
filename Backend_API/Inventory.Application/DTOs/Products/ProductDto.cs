using System;
using System.Collections.Generic;
using System.Text;

namespace Inventory.Application.DTOs.Products
{
    public class ProductDto
    {
        public int Id { get; set; }
        public string SKU { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public decimal BasePrice { get; set; }
        public string Unit { get; set; } = string.Empty;
        public string? PackingUnit { get; set; }
        public int? ConversionRate { get; set; }
        public int? CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public int TotalQuantity { get; set; }
        public int ReorderLevel { get; set; }
    }
}
