using Inventory.Application.DTOs.Orders;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Service
{
    public interface ISalesOrderService
    {
        Task<List<SalesOrderDto>> GetAllAsync();
        Task<SalesOrderDto?> GetByIdAsync(int id);
        Task<SalesOrderDto> CreateAsync(CreateSalesOrderDto dto);
        Task<bool> ApproveOrderAsync(int id);
        Task<bool> ShipOrderAsync(int id);
    }
}
