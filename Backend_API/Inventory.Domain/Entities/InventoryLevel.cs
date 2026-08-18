using System;
using System.Collections.Generic;

namespace Inventory.Domain.Entities;

public partial class InventoryLevel
{
    public int ProductId { get; set; }

    public int WarehouseId { get; set; }

    public int Quantity { get; set; }

    public DateTime? LastUpdated { get; set; }

    public virtual Product Product { get; set; } = null!;

    public virtual Warehouse Warehouse { get; set; } = null!;
}
