using Inventory.Application.DTOs.Inventory;
using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Inventory.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Inventory.Application.Services
{
    public class InventoryService : IInventoryService
    {
        private readonly IInventoryRepository _inventoryRepository;
        private readonly Microsoft.AspNetCore.Http.IHttpContextAccessor _httpContextAccessor;

        public InventoryService(IInventoryRepository inventoryRepository, Microsoft.AspNetCore.Http.IHttpContextAccessor httpContextAccessor)
        {
            _inventoryRepository = inventoryRepository;
            _httpContextAccessor = httpContextAccessor;
        }

        private int? GetCurrentUserId()
        {
            var userIdString = _httpContextAccessor.HttpContext?.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdString, out var id) ? id : (int?)null;
        }

        public async Task<List<InventoryLevelDto>> GetLevelsByProductAsync(int productId)
        {
            var levels = await _inventoryRepository.GetLevelsByProductAsync(productId);
            return levels.Select(l => new InventoryLevelDto
            {
                ProductId = l.ProductId,
                WarehouseId = l.WarehouseId,
                ProductName = l.Product.Name,
                WarehouseName = l.Warehouse.Name,
                Quantity = l.Quantity,
                LastUpdated = l.LastUpdated
            }).ToList();
        }

        public async Task<List<InventoryLevelDto>> GetLevelsByWarehouseAsync(int warehouseId)
        {
            var levels = await _inventoryRepository.GetLevelsByWarehouseAsync(warehouseId);
            return levels.Select(l => new InventoryLevelDto
            {
                ProductId = l.ProductId,
                WarehouseId = l.WarehouseId,
                ProductName = l.Product.Name,
                WarehouseName = l.Warehouse.Name,
                Quantity = l.Quantity,
                LastUpdated = l.LastUpdated
            }).ToList();
        }

        public async Task<List<TransactionHistoryDto>> GetAllTransactionsAsync()
        {
            var transactions = await _inventoryRepository.GetAllTransactionsAsync();
            return transactions.Select(t => new TransactionHistoryDto
            {
                Id = t.Id,
                ProductId = t.ProductId,
                ProductName = t.Product?.Name ?? "N/A",
                WarehouseId = t.WarehouseId,
                WarehouseName = t.Warehouse?.Name ?? "N/A",
                TransactionType = t.TransactionType,
                Quantity = t.Quantity,
                ReferenceId = t.ReferenceId,
                UserId = t.UserId,
                TransactionDate = t.TransactionDate,
                Note = t.Note
            }).ToList();
        }

        // ================= TRANSACTION MANAGEMENT =================
        public async Task BeginTransactionAsync()
        {
            await _inventoryRepository.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            await _inventoryRepository.CommitTransactionAsync();
        }

        public async Task RollbackTransactionAsync()
        {
            await _inventoryRepository.RollbackTransactionAsync();
        }
        // ========================================================

        public async Task<bool> StockInAsync(StockInOutDto dto)
        {
            if (dto.Quantity <= 0) throw new Exception("Số lượng nhập phải lớn hơn 0");

            await _inventoryRepository.BeginTransactionAsync();
            try
            {
                // 1. Cập nhật tồn kho
                var level = await _inventoryRepository.GetInventoryLevelAsync(dto.ProductId, dto.WarehouseId);
                if (level == null)
                {
                    level = new InventoryLevel
                    {
                        ProductId = dto.ProductId,
                        WarehouseId = dto.WarehouseId,
                        Quantity = dto.Quantity,
                        LastUpdated = DateTime.Now
                    };
                    await _inventoryRepository.AddInventoryLevelAsync(level);
                }
                else
                {
                    level.Quantity += dto.Quantity;
                    level.LastUpdated = DateTime.Now;
                    await _inventoryRepository.UpdateInventoryLevelAsync(level);
                }

                // 2. Ghi Log Transaction
                var log = new InventoryTransaction
                {
                    ProductId = dto.ProductId,
                    WarehouseId = dto.WarehouseId,
                    TransactionType = "IN",
                    Quantity = dto.Quantity,
                    UserId = GetCurrentUserId(),
                    TransactionDate = DateTime.Now,
                    Note = dto.Note
                };
                await _inventoryRepository.AddTransactionAsync(log);

                await _inventoryRepository.CommitTransactionAsync();
                return true;
            }
            catch (Exception)
            {
                await _inventoryRepository.RollbackTransactionAsync();
                throw;
            }
        }

        public async Task<bool> StockOutAsync(StockInOutDto dto)
        {
            if (dto.Quantity <= 0) throw new Exception("Số lượng xuất phải lớn hơn 0");

            await _inventoryRepository.BeginTransactionAsync();
            try
            {
                var level = await _inventoryRepository.GetInventoryLevelAsync(dto.ProductId, dto.WarehouseId);
                if (level == null || level.Quantity < dto.Quantity)
                {
                    throw new Exception("Không đủ số lượng trong kho để xuất!");
                }

                // 1. Cập nhật tồn kho
                level.Quantity -= dto.Quantity;
                level.LastUpdated = DateTime.Now;
                await _inventoryRepository.UpdateInventoryLevelAsync(level);

                // 2. Ghi Log Transaction
                var log = new InventoryTransaction
                {
                    ProductId = dto.ProductId,
                    WarehouseId = dto.WarehouseId,
                    TransactionType = "OUT",
                    Quantity = dto.Quantity, // Có thể lưu âm nếu muốn, nhưng thường lưu dương và dựa vào Type
                    UserId = GetCurrentUserId(),
                    TransactionDate = DateTime.Now,
                    Note = dto.Note
                };
                await _inventoryRepository.AddTransactionAsync(log);

                await _inventoryRepository.CommitTransactionAsync();
                return true;
            }
            catch (Exception)
            {
                await _inventoryRepository.RollbackTransactionAsync();
                throw;
            }
        }

        public async Task<bool> TransferAsync(TransferDto dto)
        {
            if (dto.Quantity <= 0) throw new Exception("Số lượng chuyển phải lớn hơn 0");
            if (dto.FromWarehouseId == dto.ToWarehouseId) throw new Exception("Kho nguồn và kho đích không được trùng nhau");

            await _inventoryRepository.BeginTransactionAsync();
            try
            {
                // 1. Trừ Kho Nguồn
                var fromLevel = await _inventoryRepository.GetInventoryLevelAsync(dto.ProductId, dto.FromWarehouseId);
                if (fromLevel == null || fromLevel.Quantity < dto.Quantity)
                {
                    throw new Exception("Kho nguồn không đủ số lượng để chuyển!");
                }
                fromLevel.Quantity -= dto.Quantity;
                fromLevel.LastUpdated = DateTime.Now;
                await _inventoryRepository.UpdateInventoryLevelAsync(fromLevel);

                // 2. Cộng Kho Đích
                var toLevel = await _inventoryRepository.GetInventoryLevelAsync(dto.ProductId, dto.ToWarehouseId);
                if (toLevel == null)
                {
                    toLevel = new InventoryLevel
                    {
                        ProductId = dto.ProductId,
                        WarehouseId = dto.ToWarehouseId,
                        Quantity = dto.Quantity,
                        LastUpdated = DateTime.Now
                    };
                    await _inventoryRepository.AddInventoryLevelAsync(toLevel);
                }
                else
                {
                    toLevel.Quantity += dto.Quantity;
                    toLevel.LastUpdated = DateTime.Now;
                    await _inventoryRepository.UpdateInventoryLevelAsync(toLevel);
                }

                // 3. Ghi 2 dòng Log (1 cho kho nguồn, 1 cho kho đích)
                var logOut = new InventoryTransaction
                {
                    ProductId = dto.ProductId,
                    WarehouseId = dto.FromWarehouseId,
                    TransactionType = "TRANSFER",
                    Quantity = dto.Quantity,
                    UserId = GetCurrentUserId(),
                    TransactionDate = DateTime.Now,
                    Note = $"Xuất chuyển đến kho {dto.ToWarehouseId}. {dto.Note}"
                };
                await _inventoryRepository.AddTransactionAsync(logOut);

                var logIn = new InventoryTransaction
                {
                    ProductId = dto.ProductId,
                    WarehouseId = dto.ToWarehouseId,
                    TransactionType = "TRANSFER",
                    Quantity = dto.Quantity,
                    UserId = GetCurrentUserId(),
                    TransactionDate = DateTime.Now,
                    Note = $"Nhập chuyển từ kho {dto.FromWarehouseId}. {dto.Note}"
                };
                await _inventoryRepository.AddTransactionAsync(logIn);

                await _inventoryRepository.CommitTransactionAsync();
                return true;
            }
            catch (Exception)
            {
                await _inventoryRepository.RollbackTransactionAsync();
                throw;
            }
        }
    }
}
