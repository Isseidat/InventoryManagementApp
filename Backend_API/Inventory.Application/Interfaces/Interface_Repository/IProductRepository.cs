using Inventory.Application.DTOs;
using Inventory.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Net.Http.Headers;
using System.Text;

namespace Inventory.Application.Interfaces.Interface_Repository
{
    public interface IProductRepository
    {
        Task<List<Product>> GetAllProductsAsync();
        Task<int> AddProductAsync(Product product);
        Task<bool> IsSkuExistsAsync(string sku);
        Task<bool> IsNameExistsAsync(string name);
        Task<Product?> GetProductByIdAsync(int id);
        Task UpdateProductAsync(Product product);
        Task SoftDeleteProductAsync(Product product);
    }
}
