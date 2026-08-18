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
        public string CategoryName { get; set; } = string.Empty;
    }
}
