using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Domain.Entities;
using Inventory.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Infrastructure.Repositories
{
    public class SalesOrderRepository : ISalesOrderRepository
    {
        private readonly ApplicationDbContext _context;

        public SalesOrderRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<SalesOrder>> GetAllAsync()
        {
            return await _context.SalesOrders
                .Include(so => so.Customer)
                .Include(so => so.Warehouse)
                .Include(so => so.User)
                .ToListAsync();
        }

        public async Task<SalesOrder?> GetByIdAsync(int id)
        {
            return await _context.SalesOrders
                .Include(so => so.Customer)
                .Include(so => so.Warehouse)
                .Include(so => so.User)
                .Include(so => so.SalesOrderDetails)
                    .ThenInclude(d => d.Product)
                .FirstOrDefaultAsync(so => so.Id == id);
        }

        public async Task<SalesOrder> CreateAsync(SalesOrder order)
        {
            await _context.SalesOrders.AddAsync(order);
            await _context.SaveChangesAsync();
            return order;
        }

        public async Task UpdateAsync(SalesOrder order)
        {
            _context.SalesOrders.Update(order);
            await _context.SaveChangesAsync();
        }
    }
}
