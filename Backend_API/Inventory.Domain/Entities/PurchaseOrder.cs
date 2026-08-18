using System;
using System.Collections.Generic;

namespace Inventory.Domain.Entities;

public partial class PurchaseOrder
{
    public int Id { get; set; }

    public int? SupplierId { get; set; }

    public int? UserId { get; set; }

    public int? WarehouseId { get; set; }

    public DateTime? OrderDate { get; set; }

    public string Status { get; set; } = null!;

    public virtual ICollection<PurchaseOrderDetail> PurchaseOrderDetails { get; set; } = new List<PurchaseOrderDetail>();

    public virtual Supplier? Supplier { get; set; }

    public virtual User? User { get; set; }

    public virtual Warehouse? Warehouse { get; set; }
}
