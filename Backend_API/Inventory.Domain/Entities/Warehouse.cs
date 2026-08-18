using System;
using System.Collections.Generic;

namespace Inventory.Domain.Entities;

public partial class Warehouse
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Location { get; set; }

    public virtual ICollection<InventoryLevel> InventoryLevels { get; set; } = new List<InventoryLevel>();

    public virtual ICollection<InventoryTransaction> InventoryTransactions { get; set; } = new List<InventoryTransaction>();
}
