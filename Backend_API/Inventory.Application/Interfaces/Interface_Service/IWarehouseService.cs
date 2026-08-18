using Inventory.Application.DTOs.Warehouses;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Service
{
    public interface IWarehouseService
    {
        Task<List<WarehouseDto>> GetAllWarehousesAsync();
        Task<WarehouseDto?> GetWarehouseByIdAsync(int id);
        Task<int> CreateWarehouseAsync(CreateWarehouseDto dto);
        Task<bool> UpdateWarehouseAsync(int id, UpdateWarehouseDto dto);
        Task<bool> DeleteWarehouseAsync(int id);
    }
}
