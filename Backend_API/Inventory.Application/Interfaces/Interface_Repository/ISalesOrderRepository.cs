using Inventory.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Repository
{
    public interface ISalesOrderRepository
    {
        Task<List<SalesOrder>> GetAllAsync();
        Task<SalesOrder?> GetByIdAsync(int id);
        Task<SalesOrder> CreateAsync(SalesOrder order);
        Task UpdateAsync(SalesOrder order);
    }
}
