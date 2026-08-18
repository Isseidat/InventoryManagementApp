using Inventory.Application.DTOs.User;
using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Inventory.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BCrypt.Net;

namespace Inventory.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepo;

        public UserService(IUserRepository userRepo)
        {
            _userRepo = userRepo;
        }

        public async Task<IEnumerable<UserResponseDto>> GetAllUsersAsync()
        {
            var users = await _userRepo.GetAllUsersAsync();
            return users.Select(u => new UserResponseDto
            {
                Id = u.Id,
                Username = u.Username,
                FullName = u.FullName,
                Email = u.Email,
                JobTitle = u.JobTitle,
                RoleName = u.Role?.RoleName,
                RoleId = u.RoleId
            });
        }

        public async Task<UserResponseDto?> GetUserByIdAsync(int id)
        {
            var user = await _userRepo.GetByIdAsync(id);
            if (user == null) return null;

            return new UserResponseDto
            {
                Id = user.Id,
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                JobTitle = user.JobTitle,
                RoleName = user.Role?.RoleName,
                RoleId = user.RoleId
            };
        }

        public async Task<UserResponseDto> CreateUserAsync(CreateUserDto dto)
        {
            var existingUser = await _userRepo.GetByUsernameAsync(dto.Username);
            if (existingUser != null) throw new Exception("Username đã tồn tại!");

            var role = await _userRepo.GetRoleByIdAsync(dto.RoleId);
            if (role == null) throw new Exception("Role không hợp lệ!");

            var newUser = new User
            {
                Username = dto.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                FullName = dto.FullName,
                Email = dto.Email,
                JobTitle = dto.JobTitle,
                RoleId = dto.RoleId,
                IsDeleted = false
            };

            await _userRepo.CreateAsync(newUser);

            return new UserResponseDto
            {
                Id = newUser.Id,
                Username = newUser.Username,
                FullName = newUser.FullName,
                Email = newUser.Email,
                JobTitle = newUser.JobTitle,
                RoleId = newUser.RoleId
            };
        }

        public async Task<bool> UpdateUserAsync(int id, UpdateUserDto dto)
        {
            var user = await _userRepo.GetByIdAsync(id);
            if (user == null) return false;

            var role = await _userRepo.GetRoleByIdAsync(dto.RoleId);
            if (role == null) throw new Exception("Role không hợp lệ!");

            user.FullName = dto.FullName;
            user.Email = dto.Email;
            user.JobTitle = dto.JobTitle;
            user.RoleId = dto.RoleId;

            if (!string.IsNullOrEmpty(dto.NewPassword))
            {
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            }

            await _userRepo.UpdateAsync(user);
            return true;
        }

        public async Task<bool> SoftDeleteUserAsync(int id)
        {
            var user = await _userRepo.GetByIdAsync(id);
            if (user == null) return false;

            user.IsDeleted = true;
            await _userRepo.UpdateAsync(user);
            return true;
        }
    }
}
