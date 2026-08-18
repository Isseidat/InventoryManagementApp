using System;
using System.Collections.Generic;

namespace Inventory.Domain.Entities;

public partial class SalesOrder
{
    public int Id { get; set; }

    public int? CustomerId { get; set; }

    public int? UserId { get; set; }

    public int? WarehouseId { get; set; }

    public DateTime? OrderDate { get; set; }

    public string Status { get; set; } = null!;

    public virtual Customer? Customer { get; set; }

    public virtual ICollection<SalesOrderDetail> SalesOrderDetails { get; set; } = new List<SalesOrderDetail>();

    public virtual User? User { get; set; }

    public virtual Warehouse? Warehouse { get; set; }
}
