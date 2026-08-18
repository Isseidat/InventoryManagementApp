using System;
using System.Collections.Generic;

namespace Inventory.Domain.Entities;

public partial class SalesOrderDetail
{
    public int SoId { get; set; }

    public int ProductId { get; set; }

    public int Quantity { get; set; }

    public decimal UnitPrice { get; set; }

    public virtual Product Product { get; set; } = null!;

    public virtual SalesOrder So { get; set; } = null!;
}
