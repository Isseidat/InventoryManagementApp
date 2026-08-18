using Inventory.Application.DTOs.Suppliers;
using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Inventory.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Inventory.Application.Services
{
    public class SupplierService : ISupplierService
    {
        private readonly ISupplierRepository _supplierRepository;

        public SupplierService(ISupplierRepository supplierRepository)
        {
            _supplierRepository = supplierRepository;
        }

        public async Task<List<SupplierDto>> GetAllSuppliersAsync()
        {
            var suppliers = await _supplierRepository.GetAllSuppliersAsync();
            return suppliers.Select(s => new SupplierDto
            {
                Id = s.Id,
                Name = s.Name,
                Phone = s.Phone,
                Address = s.Address
            }).ToList();
        }

        public async Task<SupplierDto?> GetSupplierByIdAsync(int id)
        {
            var supplier = await _supplierRepository.GetSupplierByIdAsync(id);
            if (supplier == null) return null;

            return new SupplierDto
            {
                Id = supplier.Id,
                Name = supplier.Name,
                Phone = supplier.Phone,
                Address = supplier.Address
            };
        }

        public async Task<int> CreateSupplierAsync(CreateSupplierDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Name))
                throw new Exception("Tên nhà cung cấp không được để trống!");

            bool isExist = await _supplierRepository.IsNameExistsAsync(dto.Name);
            if (isExist)
                throw new Exception($"Nhà cung cấp '{dto.Name}' đã tồn tại!");

            var newSupplier = new Supplier
            {
                Name = dto.Name,
                Phone = dto.Phone,
                Address = dto.Address
            };

            return await _supplierRepository.AddSupplierAsync(newSupplier);
        }

        public async Task<bool> UpdateSupplierAsync(int id, UpdateSupplierDto dto)
        {
            var supplier = await _supplierRepository.GetSupplierByIdAsync(id);
            if (supplier == null)
                throw new Exception($"Không tìm thấy nhà cung cấp ID = {id}");

            if (string.IsNullOrWhiteSpace(dto.Name))
                throw new Exception("Tên nhà cung cấp không được để trống!");

            if (dto.Name.ToLower() != supplier.Name.ToLower())
            {
                bool isExist = await _supplierRepository.IsNameExistsAsync(dto.Name);
                if (isExist) throw new Exception($"Nhà cung cấp '{dto.Name}' đã tồn tại!");
            }

            supplier.Name = dto.Name;
            supplier.Phone = dto.Phone;
            supplier.Address = dto.Address;

            await _supplierRepository.UpdateSupplierAsync(supplier);
            return true;
        }

        public async Task<bool> DeleteSupplierAsync(int id)
        {
            var supplier = await _supplierRepository.GetSupplierByIdAsync(id);
            if (supplier == null)
                throw new Exception($"Không tìm thấy nhà cung cấp ID = {id}");

            await _supplierRepository.DeleteSupplierAsync(supplier);
            return true;
        }
    }
}
