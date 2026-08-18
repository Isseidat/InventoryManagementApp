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
    public class PurchaseOrderService : IPurchaseOrderService
    {
        private readonly IPurchaseOrderRepository _poRepo;
        private readonly IInventoryService _inventoryService;
        private readonly Microsoft.AspNetCore.Http.IHttpContextAccessor _httpContextAccessor;

        public PurchaseOrderService(IPurchaseOrderRepository poRepo, IInventoryService inventoryService, Microsoft.AspNetCore.Http.IHttpContextAccessor httpContextAccessor)
        {
            _poRepo = poRepo;
            _inventoryService = inventoryService;
            _httpContextAccessor = httpContextAccessor;
        }

        private int? GetCurrentUserId()
        {
            var userIdString = _httpContextAccessor.HttpContext?.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdString, out var id) ? id : (int?)null;
        }

        public async Task<List<PurchaseOrderDto>> GetAllAsync()
        {
            var orders = await _poRepo.GetAllAsync();
            return orders.Select(o => new PurchaseOrderDto
            {
                Id = o.Id,
                SupplierId = o.SupplierId,
                SupplierName = o.Supplier?.Name,
                WarehouseId = o.WarehouseId,
                WarehouseName = o.Warehouse?.Name,
                UserId = o.UserId,
                OrderDate = o.OrderDate,
                Status = o.Status
            }).ToList();
        }

        public async Task<PurchaseOrderDto?> GetByIdAsync(int id)
        {
            var o = await _poRepo.GetByIdAsync(id);
            if (o == null) return null;

            return new PurchaseOrderDto
            {
                Id = o.Id,
                SupplierId = o.SupplierId,
                SupplierName = o.Supplier?.Name,
                WarehouseId = o.WarehouseId,
                WarehouseName = o.Warehouse?.Name,
                UserId = o.UserId,
                OrderDate = o.OrderDate,
                Status = o.Status,
                Details = o.PurchaseOrderDetails.Select(d => new OrderDetailDto
                {
                    ProductId = d.ProductId,
                    ProductName = d.Product?.Name,
                    Quantity = d.Quantity,
                    UnitPrice = d.UnitPrice
                }).ToList()
            };
        }

        public async Task<PurchaseOrderDto> CreateAsync(CreatePurchaseOrderDto dto)
        {
            var order = new PurchaseOrder
            {
                SupplierId = dto.SupplierId,
                WarehouseId = dto.WarehouseId,
                OrderDate = DateTime.Now,
                Status = "Pending",
                UserId = GetCurrentUserId()
            };

            foreach (var item in dto.Details)
            {
                order.PurchaseOrderDetails.Add(new PurchaseOrderDetail
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice
                });
            }

            await _poRepo.CreateAsync(order);

            return await GetByIdAsync(order.Id) ?? throw new Exception("Lỗi khi tạo đơn hàng");
        }

        public async Task<bool> ReceiveOrderAsync(int id)
        {
            await _inventoryService.BeginTransactionAsync();
            try
            {
                var po = await _poRepo.GetByIdAsync(id);
                if (po == null) throw new Exception("Không tìm thấy đơn hàng.");
                if (po.Status != "Pending") throw new Exception($"Không thể nhận hàng vì đơn hàng đang ở trạng thái: {po.Status}");
                if (po.WarehouseId == null) throw new Exception("Đơn hàng chưa chọn Kho nhập.");

                // 1. Đổi trạng thái PO
                po.Status = "Completed";
                await _poRepo.UpdateAsync(po);

                // 2. Nhập kho từng món
                foreach (var detail in po.PurchaseOrderDetails)
                {
                    var stockInDto = new StockInOutDto
                    {
                        ProductId = detail.ProductId,
                        WarehouseId = po.WarehouseId.Value,
                        Quantity = detail.Quantity,
                        Note = $"Nhập hàng tự động từ PO số {po.Id}"
                    };
                    await _inventoryService.StockInAsync(stockInDto);
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
