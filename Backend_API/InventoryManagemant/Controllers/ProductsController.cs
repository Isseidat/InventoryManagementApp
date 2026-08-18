using Inventory.Application.DTOs.Products;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductsController : Controller
    {
        private readonly IProductService _productService;
        public ProductsController(IProductService productService)
        {
            _productService = productService;
        }

        [HttpGet("GetAllProduct")]
        public async Task<IActionResult> GetAll()
        {
            var products = await _productService.GetAllProductsAsync();
            return Ok(products);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var product = await _productService.GetProductByIdAsync(id);
            if (product == null)
            {
                return NotFound(new { status = false, message = $"Không tìm thấy sản phẩm có ID = {id}" });
            }
            return Ok(product);
        }

        [HttpPost("PostProduct")]
        public async Task<IActionResult> CreateProduct([FromBody] CreateProductDto dto)
        {
            try
            {
                var newId = await _productService.CreateProductAsync(dto);
                return Ok(new { status = true, message = "Thêm thành công!", data = newId });
            }
            catch (Exception ex)
            {
                // Bắt lỗi nếu có trục trặc (ví dụ: DB sập, sai kiểu dữ liệu...)
                return Ok(new { status = false, message = "Thêm thất bại: " + ex.Message });
            }
        }

        // Cập nhật Sản phẩm
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProduct(int id, [FromBody] UpdateProductDto dto)
        {
            try
            {
                await _productService.UpdateProductAsync(id, dto);
                return Ok(new { status = true, message = "Cập nhật thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Cập nhật thất bại: " + ex.Message });
            }
        }

        // Xóa Mềm Sản phẩm
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            try
            {
                await _productService.DeleteProductAsync(id);
                return Ok(new { status = true, message = "Xóa sản phẩm thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Xóa thất bại: " + ex.Message });
            }
        }
    }
}
