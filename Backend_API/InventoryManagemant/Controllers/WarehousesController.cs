using Inventory.Application.DTOs.Warehouses;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WarehousesController : Controller
    {
        private readonly IWarehouseService _warehouseService;

        public WarehousesController(IWarehouseService warehouseService)
        {
            _warehouseService = warehouseService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var warehouses = await _warehouseService.GetAllWarehousesAsync();
            return Ok(warehouses);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var warehouse = await _warehouseService.GetWarehouseByIdAsync(id);
            if (warehouse == null)
            {
                return NotFound(new { status = false, message = $"Không tìm thấy kho bãi có ID = {id}" });
            }
            return Ok(warehouse);
        }

        [HttpPost]
        public async Task<IActionResult> CreateWarehouse([FromBody] CreateWarehouseDto dto)
        {
            try
            {
                var newId = await _warehouseService.CreateWarehouseAsync(dto);
                return Ok(new { status = true, message = "Thêm kho bãi thành công!", data = newId });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Thêm thất bại: " + ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateWarehouse(int id, [FromBody] UpdateWarehouseDto dto)
        {
            try
            {
                await _warehouseService.UpdateWarehouseAsync(id, dto);
                return Ok(new { status = true, message = "Cập nhật kho bãi thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Cập nhật thất bại: " + ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteWarehouse(int id)
        {
            try
            {
                await _warehouseService.DeleteWarehouseAsync(id);
                return Ok(new { status = true, message = "Xóa kho bãi thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Xóa thất bại: " + ex.Message });
            }
        }
    }
}
