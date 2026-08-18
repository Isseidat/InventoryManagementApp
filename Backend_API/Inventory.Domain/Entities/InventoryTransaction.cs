using System;
using System.Collections.Generic;

namespace Inventory.Domain.Entities;

public partial class InventoryTransaction
{
    public int Id { get; set; }

    public int? ProductId { get; set; }

    public int? WarehouseId { get; set; }

    public string TransactionType { get; set; } = null!;

    public int Quantity { get; set; }

    public int? ReferenceId { get; set; }

    public int? UserId { get; set; }

    public DateTime? TransactionDate { get; set; }

    public string? Note { get; set; }

    public virtual Product? Product { get; set; }

    public virtual User? User { get; set; }

    public virtual Warehouse? Warehouse { get; set; }
}
