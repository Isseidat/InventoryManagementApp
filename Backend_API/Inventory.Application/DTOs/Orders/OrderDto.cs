using System;
using System.Collections.Generic;

namespace Inventory.Application.DTOs.Orders
{
    // === DTO Hiển thị (Read) ===
    public class PurchaseOrderDto
    {
        public int Id { get; set; }
        public int? SupplierId { get; set; }
        public string? SupplierName { get; set; }
        public int? WarehouseId { get; set; }
        public string? WarehouseName { get; set; }
        public int? UserId { get; set; }
        public DateTime? OrderDate { get; set; }
        public string Status { get; set; } = string.Empty;
        public List<OrderDetailDto> Details { get; set; } = new();
    }

    public class SalesOrderDto
    {
        public int Id { get; set; }
        public int? CustomerId { get; set; }
        public string? CustomerName { get; set; }
        public int? WarehouseId { get; set; }
        public string? WarehouseName { get; set; }
        public int? UserId { get; set; }
        public DateTime? OrderDate { get; set; }
        public string Status { get; set; } = string.Empty;
        public List<OrderDetailDto> Details { get; set; } = new();
    }

    public class OrderDetailDto
    {
        public int ProductId { get; set; }
        public string? ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
    }

    // === DTO Tạo mới (Create) ===
    public class CreatePurchaseOrderDto
    {
        public int SupplierId { get; set; }
        public int WarehouseId { get; set; }
        public List<CreateOrderDetailDto> Details { get; set; } = new();
    }

    public class CreateSalesOrderDto
    {
        public int CustomerId { get; set; }
        public int WarehouseId { get; set; }
        public List<CreateOrderDetailDto> Details { get; set; } = new();
    }

    public class CreateOrderDetailDto
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
    }
}
