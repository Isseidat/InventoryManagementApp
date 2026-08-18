using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Domain.Entities;
using Inventory.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Inventory.Infrastructure.Repositories
{
    public class InventoryRepository : IInventoryRepository
    {
        private readonly ApplicationDbContext _context;
        private IDbContextTransaction? _currentTransaction;

        public InventoryRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<InventoryLevel?> GetInventoryLevelAsync(int productId, int warehouseId)
        {
            return await _context.InventoryLevels
                .Include(i => i.Product)
                .Include(i => i.Warehouse)
                .FirstOrDefaultAsync(i => i.ProductId == productId && i.WarehouseId == warehouseId);
        }

        public async Task<List<InventoryLevel>> GetLevelsByProductAsync(int productId)
        {
            return await _context.InventoryLevels
                .Include(i => i.Product)
                .Include(i => i.Warehouse)
                .Where(i => i.ProductId == productId)
                .ToListAsync();
        }

        public async Task<List<InventoryLevel>> GetLevelsByWarehouseAsync(int warehouseId)
        {
            return await _context.InventoryLevels
                .Include(i => i.Product)
                .Include(i => i.Warehouse)
                .Where(i => i.WarehouseId == warehouseId)
                .ToListAsync();
        }

        public async Task<List<InventoryTransaction>> GetAllTransactionsAsync()
        {
            return await _context.InventoryTransactions
                .Include(t => t.Product)
                .Include(t => t.Warehouse)
                .OrderByDescending(t => t.TransactionDate)
                .ToListAsync();
        }

        public async Task BeginTransactionAsync()
        {
            if (_currentTransaction != null) return;
            _currentTransaction = await _context.Database.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            try
            {
                await SaveChangesAsync();
                if (_currentTransaction != null)
                {
                    await _currentTransaction.CommitAsync();
                }
            }
            finally
            {
                if (_currentTransaction != null)
                {
                    await _currentTransaction.DisposeAsync();
                    _currentTransaction = null;
                }
            }
        }

        public async Task RollbackTransactionAsync()
        {
            try
            {
                if (_currentTransaction != null)
                {
                    await _currentTransaction.RollbackAsync();
                }
            }
            finally
            {
                if (_currentTransaction != null)
                {
                    await _currentTransaction.DisposeAsync();
                    _currentTransaction = null;
                }
            }
        }

        public async Task AddInventoryLevelAsync(InventoryLevel level)
        {
            await _context.InventoryLevels.AddAsync(level);
        }

        public async Task UpdateInventoryLevelAsync(InventoryLevel level)
        {
            _context.InventoryLevels.Update(level);
            await Task.CompletedTask; // Update is synchronous in EF Core
        }

        public async Task AddTransactionAsync(InventoryTransaction transaction)
        {
            await _context.InventoryTransactions.AddAsync(transaction);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
