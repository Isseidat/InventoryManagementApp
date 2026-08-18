using Inventory.Application.DTOs.Warehouses;
using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Inventory.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Inventory.Application.Services
{
    public class WarehouseService : IWarehouseService
    {
        private readonly IWarehouseRepository _warehouseRepository;

        public WarehouseService(IWarehouseRepository warehouseRepository)
        {
            _warehouseRepository = warehouseRepository;
        }

        public async Task<List<WarehouseDto>> GetAllWarehousesAsync()
        {
            var warehouses = await _warehouseRepository.GetAllWarehousesAsync();
            return warehouses.Select(w => new WarehouseDto
            {
                Id = w.Id,
                Name = w.Name,
                Location = w.Location
            }).ToList();
        }

        public async Task<WarehouseDto?> GetWarehouseByIdAsync(int id)
        {
            var warehouse = await _warehouseRepository.GetWarehouseByIdAsync(id);
            if (warehouse == null) return null;

            return new WarehouseDto
            {
                Id = warehouse.Id,
                Name = warehouse.Name,
                Location = warehouse.Location
            };
        }

        public async Task<int> CreateWarehouseAsync(CreateWarehouseDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Name))
            {
                throw new Exception("Tên kho bãi không được để trống!");
            }

            bool isExist = await _warehouseRepository.IsNameExistsAsync(dto.Name);
            if (isExist)
            {
                throw new Exception($"Kho bãi '{dto.Name}' đã tồn tại!");
            }

            var newWarehouse = new Warehouse
            {
                Name = dto.Name,
                Location = dto.Location
            };

            return await _warehouseRepository.AddWarehouseAsync(newWarehouse);
        }

        public async Task<bool> UpdateWarehouseAsync(int id, UpdateWarehouseDto dto)
        {
            var warehouse = await _warehouseRepository.GetWarehouseByIdAsync(id);
            if (warehouse == null)
            {
                throw new Exception($"Không tìm thấy kho bãi ID = {id}");
            }

            if (string.IsNullOrWhiteSpace(dto.Name))
            {
                throw new Exception("Tên kho bãi không được để trống!");
            }

            if (dto.Name.ToLower() != warehouse.Name.ToLower())
            {
                bool isExist = await _warehouseRepository.IsNameExistsAsync(dto.Name);
                if (isExist) throw new Exception($"Kho bãi '{dto.Name}' đã tồn tại!");
            }

            warehouse.Name = dto.Name;
            warehouse.Location = dto.Location;

            await _warehouseRepository.UpdateWarehouseAsync(warehouse);
            return true;
        }

        public async Task<bool> DeleteWarehouseAsync(int id)
        {
            var warehouse = await _warehouseRepository.GetWarehouseByIdAsync(id);
            if (warehouse == null)
            {
                throw new Exception($"Không tìm thấy kho bãi ID = {id}");
            }

            await _warehouseRepository.DeleteWarehouseAsync(warehouse);
            return true;
        }
    }
}
