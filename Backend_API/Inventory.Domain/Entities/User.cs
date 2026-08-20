using System;
using System.Collections.Generic;

namespace Inventory.Domain.Entities;

public partial class User
{
    public int Id { get; set; }

    public string Username { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public string FullName { get; set; } = null!;

    public string? Email { get; set; }

    public string? PhoneNumber { get; set; }

    public string? JobTitle { get; set; }

    public int? RoleId { get; set; }

    public bool IsDeleted { get; set; }

    public virtual ICollection<InventoryTransaction> InventoryTransactions { get; set; } = new List<InventoryTransaction>();

    public virtual ICollection<PurchaseOrder> PurchaseOrders { get; set; } = new List<PurchaseOrder>();

    public virtual Role? Role { get; set; }

    public virtual ICollection<SalesOrder> SalesOrders { get; set; } = new List<SalesOrder>();
}
