using Inventory.Application.DTOs.Customers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Service
{
    public interface ICustomerService
    {
        Task<List<CustomerDto>> GetAllCustomersAsync();
        Task<CustomerDto?> GetCustomerByIdAsync(int id);
        Task<int> CreateCustomerAsync(CreateCustomerDto dto);
        Task<bool> UpdateCustomerAsync(int id, UpdateCustomerDto dto);
        Task<bool> DeleteCustomerAsync(int id);
    }
}
