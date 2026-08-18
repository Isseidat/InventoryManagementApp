using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Domain.Entities;
using Inventory.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Infrastructure.Repositories
{
    public class PurchaseOrderRepository : IPurchaseOrderRepository
    {
        private readonly ApplicationDbContext _context;

        public PurchaseOrderRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<PurchaseOrder>> GetAllAsync()
        {
            return await _context.PurchaseOrders
                .Include(po => po.Supplier)
                .Include(po => po.Warehouse)
                .Include(po => po.User)
                .ToListAsync();
        }

        public async Task<PurchaseOrder?> GetByIdAsync(int id)
        {
            return await _context.PurchaseOrders
                .Include(po => po.Supplier)
                .Include(po => po.Warehouse)
                .Include(po => po.User)
                .Include(po => po.PurchaseOrderDetails)
                    .ThenInclude(d => d.Product)
                .FirstOrDefaultAsync(po => po.Id == id);
        }

        public async Task<PurchaseOrder> CreateAsync(PurchaseOrder order)
        {
            await _context.PurchaseOrders.AddAsync(order);
            await _context.SaveChangesAsync();
            return order;
        }

        public async Task UpdateAsync(PurchaseOrder order)
        {
            _context.PurchaseOrders.Update(order);
            await _context.SaveChangesAsync();
        }
    }
}
