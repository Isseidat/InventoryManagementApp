using Inventory.Application.DTOs.Inventory;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class InventoryController : Controller
    {
        private readonly IInventoryService _inventoryService;

        public InventoryController(IInventoryService inventoryService)
        {
            _inventoryService = inventoryService;
        }

        // ================= LEVELS (Mức tồn kho) =================

        [HttpGet("Levels/Product/{productId}")]
        public async Task<IActionResult> GetLevelsByProduct(int productId)
        {
            var levels = await _inventoryService.GetLevelsByProductAsync(productId);
            return Ok(levels);
        }

        [HttpGet("Levels/Warehouse/{warehouseId}")]
        public async Task<IActionResult> GetLevelsByWarehouse(int warehouseId)
        {
            var levels = await _inventoryService.GetLevelsByWarehouseAsync(warehouseId);
            return Ok(levels);
        }

        // ================= TRANSACTIONS (Giao dịch) =================

        [HttpGet("Transactions")]
        public async Task<IActionResult> GetAllTransactions()
        {
            var transactions = await _inventoryService.GetAllTransactionsAsync();
            return Ok(transactions);
        }

        [HttpPost("Transactions/StockIn")]
        public async Task<IActionResult> StockIn([FromBody] StockInOutDto dto)
        {
            try
            {
                await _inventoryService.StockInAsync(dto);
                return Ok(new { status = true, message = "Nhập kho thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Nhập kho thất bại: " + ex.Message });
            }
        }

        [HttpPost("Transactions/StockOut")]
        public async Task<IActionResult> StockOut([FromBody] StockInOutDto dto)
        {
            try
            {
                await _inventoryService.StockOutAsync(dto);
                return Ok(new { status = true, message = "Xuất kho thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Xuất kho thất bại: " + ex.Message });
            }
        }

        [HttpPost("Transactions/Transfer")]
        public async Task<IActionResult> Transfer([FromBody] TransferDto dto)
        {
            try
            {
                await _inventoryService.TransferAsync(dto);
                return Ok(new { status = true, message = "Chuyển kho thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Chuyển kho thất bại: " + ex.Message });
            }
        }
    }
}
