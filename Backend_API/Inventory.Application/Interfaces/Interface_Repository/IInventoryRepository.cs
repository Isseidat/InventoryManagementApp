using Inventory.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Repository
{
    public interface IInventoryRepository
    {
        Task<InventoryLevel?> GetInventoryLevelAsync(int productId, int warehouseId);
        Task<List<InventoryLevel>> GetLevelsByProductAsync(int productId);
        Task<List<InventoryLevel>> GetLevelsByWarehouseAsync(int warehouseId);
        Task<List<InventoryTransaction>> GetAllTransactionsAsync();
        
        // Transaction logic (No EF Core dependency)
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
        Task AddInventoryLevelAsync(InventoryLevel level);
        Task UpdateInventoryLevelAsync(InventoryLevel level);
        Task AddTransactionAsync(InventoryTransaction transaction);
        Task SaveChangesAsync();
    }
}
