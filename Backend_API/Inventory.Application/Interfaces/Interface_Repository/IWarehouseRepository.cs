using Inventory.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Repository
{
    public interface IWarehouseRepository
    {
        Task<List<Warehouse>> GetAllWarehousesAsync();
        Task<Warehouse?> GetWarehouseByIdAsync(int id);
        Task<int> AddWarehouseAsync(Warehouse warehouse);
        Task UpdateWarehouseAsync(Warehouse warehouse);
        Task DeleteWarehouseAsync(Warehouse warehouse);
        Task<bool> IsNameExistsAsync(string name);
    }
}
