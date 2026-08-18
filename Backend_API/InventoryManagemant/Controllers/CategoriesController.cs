using Inventory.Application.DTOs.Categories;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : Controller
    {
        private readonly ICategoryService _categoryService;

        public CategoriesController(ICategoryService categoryService)
        {
            _categoryService = categoryService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var categories = await _categoryService.GetAllCategoriesAsync();
            return Ok(categories);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var category = await _categoryService.GetCategoryByIdAsync(id);
            if (category == null)
            {
                return NotFound(new { status = false, message = $"Không tìm thấy danh mục có ID = {id}" });
            }
            return Ok(category);
        }

        [HttpPost]
        public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryDto dto)
        {
            try
            {
                var newId = await _categoryService.CreateCategoryAsync(dto);
                return Ok(new { status = true, message = "Thêm danh mục thành công!", data = newId });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Thêm thất bại: " + ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCategory(int id, [FromBody] UpdateCategoryDto dto)
        {
            try
            {
                await _categoryService.UpdateCategoryAsync(id, dto);
                return Ok(new { status = true, message = "Cập nhật danh mục thành công!" });
            }
            catch (Exception ex)
            {
                return Ok(new { status = false, message = "Cập nhật thất bại: " + ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            try
            {
                await _categoryService.DeleteCategoryAsync(id);
                return Ok(new { status = true, message = "Xóa danh mục thành công!" });
            }
            catch (Exception ex)
            {
                // Nếu dính lỗi Khóa Ngoại (Foreign Key) do đang chứa Sản phẩm, nó sẽ nhảy vào đây
                return Ok(new { status = false, message = "Xóa thất bại: " + ex.Message });
            }
        }
    }
}
