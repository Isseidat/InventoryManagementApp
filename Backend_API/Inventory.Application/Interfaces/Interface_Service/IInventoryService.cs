using Inventory.Application.DTOs.Inventory;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Service
{
    public interface IInventoryService
    {
        Task<List<InventoryLevelDto>> GetLevelsByProductAsync(int productId);
        Task<List<InventoryLevelDto>> GetLevelsByWarehouseAsync(int warehouseId);
        Task<List<TransactionHistoryDto>> GetAllTransactionsAsync();

        Task<bool> StockInAsync(StockInOutDto dto);
        Task<bool> StockOutAsync(StockInOutDto dto);
        Task<bool> TransferAsync(TransferDto dto);

        // Transaction Management cho các Service khác xài ké
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}
