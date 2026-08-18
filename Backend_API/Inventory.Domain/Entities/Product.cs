using System;
using System.Collections.Generic;

namespace Inventory.Domain.Entities;

public partial class Product
{
    public int Id { get; set; }

    public string Sku { get; set; } = null!;

    public string? Barcode { get; set; }

    public string Name { get; set; } = null!;

    public int? CategoryId { get; set; }

    public decimal BasePrice { get; set; }

    public string Unit { get; set; } = null!;

    public int ReorderLevel { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public bool IsDeleted { get; set; } = false;

    public virtual Category? Category { get; set; }

    public virtual ICollection<InventoryLevel> InventoryLevels { get; set; } = new List<InventoryLevel>();

    public virtual ICollection<InventoryTransaction> InventoryTransactions { get; set; } = new List<InventoryTransaction>();

    public virtual ICollection<PurchaseOrderDetail> PurchaseOrderDetails { get; set; } = new List<PurchaseOrderDetail>();

    public virtual ICollection<SalesOrderDetail> SalesOrderDetails { get; set; } = new List<SalesOrderDetail>();
}
