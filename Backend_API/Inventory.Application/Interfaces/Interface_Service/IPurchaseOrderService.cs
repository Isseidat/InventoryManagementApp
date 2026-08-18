using Inventory.Application.DTOs.Orders;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Service
{
    public interface IPurchaseOrderService
    {
        Task<List<PurchaseOrderDto>> GetAllAsync();
        Task<PurchaseOrderDto?> GetByIdAsync(int id);
        Task<PurchaseOrderDto> CreateAsync(CreatePurchaseOrderDto dto);
        Task<bool> ReceiveOrderAsync(int id);
    }
}
