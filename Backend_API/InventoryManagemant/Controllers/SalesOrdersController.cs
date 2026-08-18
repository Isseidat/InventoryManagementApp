using Inventory.Application.DTOs.Orders;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Bắt buộc đăng nhập cho toàn bộ Controller này
    public class SalesOrdersController : Controller
    {
        private readonly ISalesOrderService _soService;

        public SalesOrdersController(ISalesOrderService soService)
        {
            _soService = soService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            return Ok(await _soService.GetAllAsync());
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var order = await _soService.GetByIdAsync(id);
            if (order == null) return NotFound();
            return Ok(order);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateSalesOrderDto dto)
        {
            try
            {
                var order = await _soService.CreateAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = order.Id }, order);
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, message = ex.Message });
            }
        }

        [HttpPut("{id}/Approve")]
        [Authorize(Roles = "Admin,Manager")] // Chỉ có Admin hoặc Manager mới được duyệt đơn
        public async Task<IActionResult> Approve(int id)
        {
            try
            {
                await _soService.ApproveOrderAsync(id);
                return Ok(new { status = true, message = "Đơn bán hàng đã được duyệt!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, message = ex.Message });
            }
        }

        [HttpPut("{id}/Ship")]
        public async Task<IActionResult> Ship(int id)
        {
            try
            {
                await _soService.ShipOrderAsync(id);
                return Ok(new { status = true, message = "Đã xuất kho và giao hàng thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, message = ex.Message });
            }
        }
    }
}
