using Inventory.Application.DTOs.Customers;
using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Inventory.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Inventory.Application.Services
{
    public class CustomerService : ICustomerService
    {
        private readonly ICustomerRepository _customerRepository;

        public CustomerService(ICustomerRepository customerRepository)
        {
            _customerRepository = customerRepository;
        }

        public async Task<List<CustomerDto>> GetAllCustomersAsync()
        {
            var customers = await _customerRepository.GetAllCustomersAsync();
            return customers.Select(c => new CustomerDto
            {
                Id = c.Id,
                Name = c.Name,
                Phone = c.Phone,
                Address = c.Address
            }).ToList();
        }

        public async Task<CustomerDto?> GetCustomerByIdAsync(int id)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            if (customer == null) return null;

            return new CustomerDto
            {
                Id = customer.Id,
                Name = customer.Name,
                Phone = customer.Phone,
                Address = customer.Address
            };
        }

        public async Task<int> CreateCustomerAsync(CreateCustomerDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Name))
                throw new Exception("Tên khách hàng không được để trống!");

            bool isExist = await _customerRepository.IsNameExistsAsync(dto.Name);
            if (isExist)
                throw new Exception($"Khách hàng '{dto.Name}' đã tồn tại!");

            var newCustomer = new Customer
            {
                Name = dto.Name,
                Phone = dto.Phone,
                Address = dto.Address
            };

            return await _customerRepository.AddCustomerAsync(newCustomer);
        }

        public async Task<bool> UpdateCustomerAsync(int id, UpdateCustomerDto dto)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            if (customer == null)
                throw new Exception($"Không tìm thấy khách hàng ID = {id}");

            if (string.IsNullOrWhiteSpace(dto.Name))
                throw new Exception("Tên khách hàng không được để trống!");

            if (dto.Name.ToLower() != customer.Name.ToLower())
            {
                bool isExist = await _customerRepository.IsNameExistsAsync(dto.Name);
                if (isExist) throw new Exception($"Khách hàng '{dto.Name}' đã tồn tại!");
            }

            customer.Name = dto.Name;
            customer.Phone = dto.Phone;
            customer.Address = dto.Address;

            await _customerRepository.UpdateCustomerAsync(customer);
            return true;
        }

        public async Task<bool> DeleteCustomerAsync(int id)
        {
            var customer = await _customerRepository.GetCustomerByIdAsync(id);
            if (customer == null)
                throw new Exception($"Không tìm thấy khách hàng ID = {id}");

            await _customerRepository.DeleteCustomerAsync(customer);
            return true;
        }
    }
}
