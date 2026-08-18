using Inventory.Application.DTOs.Categories;
using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Inventory.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Inventory.Application.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly ICategoryRepository _categoryRepository;

        public CategoryService(ICategoryRepository categoryRepository)
        {
            _categoryRepository = categoryRepository;
        }

        public async Task<List<CategoryDto>> GetAllCategoriesAsync()
        {
            var categories = await _categoryRepository.GetAllCategoriesAsync();
            return categories.Select(c => new CategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                Description = c.Description
            }).ToList();
        }

        public async Task<CategoryDto?> GetCategoryByIdAsync(int id)
        {
            var category = await _categoryRepository.GetCategoryByIdAsync(id);
            if (category == null) return null;

            return new CategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                Description = category.Description
            };
        }

        public async Task<int> CreateCategoryAsync(CreateCategoryDto dto)
        {
            // 1. Kiểm tra đầu vào
            if (string.IsNullOrWhiteSpace(dto.Name))
            {
                throw new Exception("Tên danh mục không được để trống!");
            }

            // 2. Kiểm tra trùng lặp
            bool isExist = await _categoryRepository.IsNameExistsAsync(dto.Name);
            if (isExist)
            {
                throw new Exception($"Danh mục '{dto.Name}' đã tồn tại!");
            }

            // 3. Tạo mới
            var newCategory = new Category
            {
                Name = dto.Name,
                Description = dto.Description
            };

            return await _categoryRepository.AddCategoryAsync(newCategory);
        }

        public async Task<bool> UpdateCategoryAsync(int id, UpdateCategoryDto dto)
        {
            var category = await _categoryRepository.GetCategoryByIdAsync(id);
            if (category == null)
            {
                throw new Exception($"Không tìm thấy danh mục ID = {id}");
            }

            if (string.IsNullOrWhiteSpace(dto.Name))
            {
                throw new Exception("Tên danh mục không được để trống!");
            }

            // Kiểm tra trùng tên nếu đổi tên mới
            if (dto.Name.ToLower() != category.Name.ToLower())
            {
                bool isExist = await _categoryRepository.IsNameExistsAsync(dto.Name);
                if (isExist) throw new Exception($"Danh mục '{dto.Name}' đã tồn tại!");
            }

            category.Name = dto.Name;
            category.Description = dto.Description;

            await _categoryRepository.UpdateCategoryAsync(category);
            return true;
        }

        public async Task<bool> DeleteCategoryAsync(int id)
        {
            var category = await _categoryRepository.GetCategoryByIdAsync(id);
            if (category == null)
            {
                throw new Exception($"Không tìm thấy danh mục ID = {id}");
            }

            await _categoryRepository.DeleteCategoryAsync(category);
            return true;
        }
    }
}
