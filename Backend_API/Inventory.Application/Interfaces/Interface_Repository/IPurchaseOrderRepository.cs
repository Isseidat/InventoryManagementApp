using Inventory.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Repository
{
    public interface IPurchaseOrderRepository
    {
        Task<List<PurchaseOrder>> GetAllAsync();
        Task<PurchaseOrder?> GetByIdAsync(int id);
        Task<PurchaseOrder> CreateAsync(PurchaseOrder order);
        Task UpdateAsync(PurchaseOrder order);
    }
}
