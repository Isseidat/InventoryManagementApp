using Inventory.Application.DTOs.Inventory;
using Inventory.Application.DTOs.Orders;
using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Inventory.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Inventory.Application.Services
{
    public class SalesOrderService : ISalesOrderService
    {
        private readonly ISalesOrderRepository _soRepo;
        private readonly IInventoryService _inventoryService;
        private readonly Microsoft.AspNetCore.Http.IHttpContextAccessor _httpContextAccessor;

        public SalesOrderService(ISalesOrderRepository soRepo, IInventoryService inventoryService, Microsoft.AspNetCore.Http.IHttpContextAccessor httpContextAccessor)
        {
            _soRepo = soRepo;
            _inventoryService = inventoryService;
            _httpContextAccessor = httpContextAccessor;
        }

        private int? GetCurrentUserId()
        {
            var userIdString = _httpContextAccessor.HttpContext?.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdString, out var id) ? id : (int?)null;
        }

        public async Task<List<SalesOrderDto>> GetAllAsync()
        {
            var orders = await _soRepo.GetAllAsync();
            return orders.Select(o => new SalesOrderDto
            {
                Id = o.Id,
                CustomerId = o.CustomerId,
                CustomerName = o.Customer?.Name,
                WarehouseId = o.WarehouseId,
                WarehouseName = o.Warehouse?.Name,
                UserId = o.UserId,
                OrderDate = o.OrderDate,
                Status = o.Status
            }).ToList();
        }

        public async Task<SalesOrderDto?> GetByIdAsync(int id)
        {
            var o = await _soRepo.GetByIdAsync(id);
            if (o == null) return null;

            return new SalesOrderDto
            {
                Id = o.Id,
                CustomerId = o.CustomerId,
                CustomerName = o.Customer?.Name,
                WarehouseId = o.WarehouseId,
                WarehouseName = o.Warehouse?.Name,
                UserId = o.UserId,
                OrderDate = o.OrderDate,
                Status = o.Status,
                Details = o.SalesOrderDetails.Select(d => new OrderDetailDto
                {
                    ProductId = d.ProductId,
                    ProductName = d.Product?.Name,
                    Quantity = d.Quantity,
                    UnitPrice = d.UnitPrice
                }).ToList()
            };
        }

        public async Task<SalesOrderDto> CreateAsync(CreateSalesOrderDto dto)
        {
            var order = new SalesOrder
            {
                CustomerId = dto.CustomerId,
                WarehouseId = dto.WarehouseId,
                OrderDate = DateTime.Now,
                Status = "Pending",
                UserId = GetCurrentUserId()
            };

            foreach (var item in dto.Details)
            {
                order.SalesOrderDetails.Add(new SalesOrderDetail
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice
                });
            }

            await _soRepo.CreateAsync(order);

            return await GetByIdAsync(order.Id) ?? throw new Exception("Lỗi khi tạo đơn bán hàng");
        }

        public async Task<bool> ApproveOrderAsync(int id)
        {
            var so = await _soRepo.GetByIdAsync(id);
            if (so == null) throw new Exception("Không tìm thấy đơn hàng.");
            if (so.Status != "Pending") throw new Exception($"Đơn hàng đang ở trạng thái: {so.Status}");

            so.Status = "Approved";
            await _soRepo.UpdateAsync(so);
            return true;
        }

        public async Task<bool> ShipOrderAsync(int id)
        {
            await _inventoryService.BeginTransactionAsync();
            try
            {
                var so = await _soRepo.GetByIdAsync(id);
                if (so == null) throw new Exception("Không tìm thấy đơn hàng.");
                if (so.Status != "Approved") throw new Exception($"Chỉ có thể xuất giao hàng khi đơn đã Approved (Trạng thái hiện tại: {so.Status})");
                if (so.WarehouseId == null) throw new Exception("Đơn hàng chưa chọn Kho xuất.");

                // 1. Đổi trạng thái SO
                so.Status = "Shipped";
                await _soRepo.UpdateAsync(so);

                // 2. Xuất kho từng món
                foreach (var detail in so.SalesOrderDetails)
                {
                    var stockOutDto = new StockInOutDto
                    {
                        ProductId = detail.ProductId,
                        WarehouseId = so.WarehouseId.Value,
                        Quantity = detail.Quantity,
                        Note = $"Xuất hàng tự động cho SO số {so.Id}"
                    };
                    await _inventoryService.StockOutAsync(stockOutDto);
                }

                await _inventoryService.CommitTransactionAsync();
                return true;
            }
            catch
            {
                await _inventoryService.RollbackTransactionAsync();
                throw;
            }
        }
    }
}
