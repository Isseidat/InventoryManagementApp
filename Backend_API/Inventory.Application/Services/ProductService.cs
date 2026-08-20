using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using System.Linq;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Inventory.Domain.Entities;
using Inventory.Application.DTOs.Products;

namespace Inventory.Application.Services
{
    public class ProductService : IProductService
    {
        private readonly IProductRepository _productRepository;
        
        public ProductService(IProductRepository productRepository)
        {
            _productRepository = productRepository;
        }
        
        public async Task<List<ProductDto>> GetAllProductsAsync()
        {
            var products = await _productRepository.GetAllProductsAsync();

            var productDtos = products.Select(p => new ProductDto
            {
                Id = p.Id,
                SKU = p.Sku,
                Name = p.Name,
                BasePrice = p.BasePrice,
                Unit = p.Unit,
                PackingUnit = p.PackingUnit,
                ConversionRate = p.ConversionRate,
                CategoryId = p.CategoryId,
                CategoryName = p.Category != null ? p.Category.Name : "Không có danh mục",
                TotalQuantity = p.InventoryLevels.Sum(il => il.Quantity),
                ReorderLevel = p.ReorderLevel
            }).ToList();

            return productDtos;
        }

        public async Task<ProductDto?> GetProductByIdAsync(int id)
        {
            var product = await _productRepository.GetProductByIdAsync(id);
            if (product == null) return null;

            return new ProductDto
            {
                Id = product.Id,
                SKU = product.Sku,
                Name = product.Name,
                BasePrice = product.BasePrice,
                Unit = product.Unit,
                PackingUnit = product.PackingUnit,
                ConversionRate = product.ConversionRate,
                CategoryId = product.CategoryId,
                CategoryName = product.Category != null ? product.Category.Name : "Không có danh mục",
                TotalQuantity = product.InventoryLevels.Sum(il => il.Quantity),
                ReorderLevel = product.ReorderLevel
            };
        }

        public async Task<int> CreateProductAsync(CreateProductDto dto)
        {
            // --- 1. KIỂM TRA DỮ LIỆU ĐẦU VÀO (VALIDATION) ---
            if (string.IsNullOrWhiteSpace(dto.Name))
            {
                throw new Exception("Tên sản phẩm không được để trống!");
            }
            if (dto.BasePrice < 0)
            {
                throw new Exception("Giá sản phẩm không được là số âm!");
            }

            // --- 2. KIỂM TRA TRÙNG LẶP SKU VÀ TÊN ---
            bool isSkuExist = await _productRepository.IsSkuExistsAsync(dto.SKU);
            if (isSkuExist)
            {
                throw new Exception($"Mã SKU '{dto.SKU}' đã tồn tại trong hệ thống!");
            }

            bool isNameExist = await _productRepository.IsNameExistsAsync(dto.Name);
            if (isNameExist)
            {
                throw new Exception($"Tên sản phẩm '{dto.Name}' đã tồn tại! Vui lòng chọn tên khác.");
            }

            // --- 3. TIẾN HÀNH LƯU (Nếu mọi thứ hợp lệ) ---
            var newProduct = new Product
            {
                Sku = dto.SKU,
                Barcode = dto.Barcode,
                Name = dto.Name,
                CategoryId = dto.CategoryId,
                BasePrice = dto.BasePrice,
                Unit = dto.Unit,
                PackingUnit = dto.PackingUnit,
                ConversionRate = dto.ConversionRate,
                ReorderLevel = dto.ReorderLevel,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now,
            };

            var newId = await _productRepository.AddProductAsync(newProduct);
            return newId;
        }

        public async Task<bool> UpdateProductAsync(int id, UpdateProductDto dto)
        {
            // 1. Tìm sản phẩm cũ trong kho
            var product = await _productRepository.GetProductByIdAsync(id);
            if (product == null)
            {
                throw new Exception($"Không tìm thấy sản phẩm có mã ID = {id}");
            }

            // 2. Validate dữ liệu mới
            if (string.IsNullOrWhiteSpace(dto.Name)) throw new Exception("Tên sản phẩm không được để trống!");
            if (dto.BasePrice < 0) throw new Exception("Giá sản phẩm không được là số âm!");

            // Kiểm tra trùng SKU nếu họ cố tình đổi SKU sang một SKU đã có của người khác
            if (dto.SKU != product.Sku)
            {
                bool isSkuExist = await _productRepository.IsSkuExistsAsync(dto.SKU);
                if (isSkuExist) throw new Exception($"Mã SKU '{dto.SKU}' đã bị người khác sử dụng!");
            }

            // 3. Đắp dữ liệu mới đè lên cái cũ
            product.Sku = dto.SKU;
            product.Barcode = dto.Barcode;
            product.Name = dto.Name;
            product.CategoryId = dto.CategoryId;
            product.BasePrice = dto.BasePrice;
            product.Unit = dto.Unit;
            product.PackingUnit = dto.PackingUnit;
            product.ConversionRate = dto.ConversionRate;
            product.ReorderLevel = dto.ReorderLevel;
            product.UpdatedAt = DateTime.Now;

            // 4. Lưu lại
            await _productRepository.UpdateProductAsync(product);
            return true;
        }

        public async Task<bool> DeleteProductAsync(int id)
        {
            var product = await _productRepository.GetProductByIdAsync(id);
            if (product == null)
            {
                throw new Exception($"Không tìm thấy sản phẩm có mã ID = {id}");
            }

            if (product.InventoryLevels.Sum(il => il.Quantity) > 0)
            {
                throw new Exception("Không thể xóa sản phẩm này vì vẫn còn hàng tồn kho!");
            }

            // Gọi hàm Xóa Mềm
            await _productRepository.SoftDeleteProductAsync(product);
            return true;
        }
    }
}
