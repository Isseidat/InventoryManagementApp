using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Domain.Entities;
using Inventory.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace Inventory.Infrastructure.Repositories
{
    public class ProductRepository : IProductRepository
    {
        private readonly ApplicationDbContext _context;
        
        public ProductRepository(ApplicationDbContext context)
        {
            _context = context;
        }
        public async Task<List<Product>> GetAllProductsAsync()
        {
            // Chỉ lấy những sản phẩm CHƯA BỊ XÓA
            return await _context.Products
                .Include(p => p.Category)
                .Where(p => p.IsDeleted == false)
                .ToListAsync();
        }
        public async Task<int> AddProductAsync(Product product)
        {
            _context.Products.Add(product);

            await _context.SaveChangesAsync();

            return product.Id;
        }

        public async Task<bool> IsSkuExistsAsync(string sku)
        {
            return await _context.Products.AnyAsync(p => p.Sku == sku);
        }

        public async Task<bool> IsNameExistsAsync(string name)
        {
            return await _context.Products.AnyAsync(p => p.Name.ToLower() == name.ToLower() && p.IsDeleted == false);
        }

        public async Task<Product?> GetProductByIdAsync(int id)
        {
            return await _context.Products.FirstOrDefaultAsync(p => p.Id == id && p.IsDeleted == false);
        }

        public async Task UpdateProductAsync(Product product)
        {
            _context.Products.Update(product);
            await _context.SaveChangesAsync();
        }

        public async Task SoftDeleteProductAsync(Product product)
        {
            product.IsDeleted = true; // Chuyển trạng thái
            _context.Products.Update(product);
            await _context.SaveChangesAsync();
        }
    }
}
