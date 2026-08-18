using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Domain.Entities;
using Inventory.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Infrastructure.Repositories
{
    public class WarehouseRepository : IWarehouseRepository
    {
        private readonly ApplicationDbContext _context;

        public WarehouseRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Warehouse>> GetAllWarehousesAsync()
        {
            return await _context.Warehouses.ToListAsync();
        }

        public async Task<Warehouse?> GetWarehouseByIdAsync(int id)
        {
            return await _context.Warehouses.FirstOrDefaultAsync(w => w.Id == id);
        }

        public async Task<int> AddWarehouseAsync(Warehouse warehouse)
        {
            _context.Warehouses.Add(warehouse);
            await _context.SaveChangesAsync();
            return warehouse.Id;
        }

        public async Task UpdateWarehouseAsync(Warehouse warehouse)
        {
            _context.Warehouses.Update(warehouse);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteWarehouseAsync(Warehouse warehouse)
        {
            _context.Warehouses.Remove(warehouse);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> IsNameExistsAsync(string name)
        {
            return await _context.Warehouses.AnyAsync(w => w.Name.ToLower() == name.ToLower());
        }
    }
}
