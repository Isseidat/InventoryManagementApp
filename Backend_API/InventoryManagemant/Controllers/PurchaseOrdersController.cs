using Inventory.Application.DTOs.Orders;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PurchaseOrdersController : Controller
    {
        private readonly IPurchaseOrderService _poService;

        public PurchaseOrdersController(IPurchaseOrderService poService)
        {
            _poService = poService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            return Ok(await _poService.GetAllAsync());
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var order = await _poService.GetByIdAsync(id);
            if (order == null) return NotFound();
            return Ok(order);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreatePurchaseOrderDto dto)
        {
            try
            {
                var order = await _poService.CreateAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = order.Id }, order);
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, message = ex.Message });
            }
        }

        [HttpPut("{id}/Receive")]
        public async Task<IActionResult> Receive(int id)
        {
            try
            {
                await _poService.ReceiveOrderAsync(id);
                return Ok(new { status = true, message = "Đã nhận hàng thành công và tự động nhập kho!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, message = ex.Message });
            }
        }
    }
}
