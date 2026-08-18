using Inventory.Application.DTOs.Suppliers;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SuppliersController : Controller
    {
        private readonly ISupplierService _supplierService;

        public SuppliersController(ISupplierService supplierService)
        {
            _supplierService = supplierService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var suppliers = await _supplierService.GetAllSuppliersAsync();
            return Ok(suppliers);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var supplier = await _supplierService.GetSupplierByIdAsync(id);
            if (supplier == null)
            {
                return NotFound(new { status = false, message = $"Không tìm thấy nhà cung cấp có ID = {id}" });
            }
            return Ok(supplier);
        }

        [HttpPost]
        public async Task<IActionResult> CreateSupplier([FromBody] CreateSupplierDto dto)
        {
            try
            {
                var newId = await _supplierService.CreateSupplierAsync(dto);
                return Ok(new { status = true, message = "Thêm nhà cung cấp thành công!", data = newId });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Thêm thất bại: " + ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSupplier(int id, [FromBody] UpdateSupplierDto dto)
        {
            try
            {
                await _supplierService.UpdateSupplierAsync(id, dto);
                return Ok(new { status = true, message = "Cập nhật nhà cung cấp thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Cập nhật thất bại: " + ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSupplier(int id)
        {
            try
            {
                await _supplierService.DeleteSupplierAsync(id);
                return Ok(new { status = true, message = "Xóa nhà cung cấp thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Xóa thất bại: " + ex.Message });
            }
        }
    }
}
