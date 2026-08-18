using System;

namespace Inventory.Application.DTOs.Inventory
{
    public class InventoryLevelDto
    {
        public int ProductId { get; set; }
        public int WarehouseId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string WarehouseName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public DateTime? LastUpdated { get; set; }
    }

    public class TransactionHistoryDto
    {
        public int Id { get; set; }
        public int? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public int? WarehouseId { get; set; }
        public string WarehouseName { get; set; } = string.Empty;
        public string TransactionType { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public int? ReferenceId { get; set; }
        public int? UserId { get; set; }
        public DateTime? TransactionDate { get; set; }
        public string? Note { get; set; }
    }

    public class StockInOutDto
    {
        public int ProductId { get; set; }
        public int WarehouseId { get; set; }
        public int Quantity { get; set; }
        public string? Note { get; set; }
    }

    public class TransferDto
    {
        public int ProductId { get; set; }
        public int FromWarehouseId { get; set; }
        public int ToWarehouseId { get; set; }
        public int Quantity { get; set; }
        public string? Note { get; set; }
    }
}
