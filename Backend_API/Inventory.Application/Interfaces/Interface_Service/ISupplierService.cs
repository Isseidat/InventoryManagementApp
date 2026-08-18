using Inventory.Application.DTOs.Suppliers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Service
{
    public interface ISupplierService
    {
        Task<List<SupplierDto>> GetAllSuppliersAsync();
        Task<SupplierDto?> GetSupplierByIdAsync(int id);
        Task<int> CreateSupplierAsync(CreateSupplierDto dto);
        Task<bool> UpdateSupplierAsync(int id, UpdateSupplierDto dto);
        Task<bool> DeleteSupplierAsync(int id);
    }
}
