using Inventory.Application.DTOs.Customers;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CustomersController : Controller
    {
        private readonly ICustomerService _customerService;

        public CustomersController(ICustomerService customerService)
        {
            _customerService = customerService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var customers = await _customerService.GetAllCustomersAsync();
            return Ok(customers);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var customer = await _customerService.GetCustomerByIdAsync(id);
            if (customer == null)
            {
                return NotFound(new { status = false, message = $"Không tìm thấy khách hàng có ID = {id}" });
            }
            return Ok(customer);
        }

        [HttpPost]
        public async Task<IActionResult> CreateCustomer([FromBody] CreateCustomerDto dto)
        {
            try
            {
                var newId = await _customerService.CreateCustomerAsync(dto);
                return Ok(new { status = true, message = "Thêm khách hàng thành công!", data = newId });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Thêm thất bại: " + ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCustomer(int id, [FromBody] UpdateCustomerDto dto)
        {
            try
            {
                await _customerService.UpdateCustomerAsync(id, dto);
                return Ok(new { status = true, message = "Cập nhật khách hàng thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Cập nhật thất bại: " + ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCustomer(int id)
        {
            try
            {
                await _customerService.DeleteCustomerAsync(id);
                return Ok(new { status = true, message = "Xóa khách hàng thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Xóa thất bại: " + ex.Message });
            }
        }
    }
}
