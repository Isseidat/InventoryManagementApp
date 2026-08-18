using Inventory.Application.DTOs.User;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Service
{
    public interface IUserService
    {
        Task<IEnumerable<UserResponseDto>> GetAllUsersAsync();
        Task<UserResponseDto?> GetUserByIdAsync(int id);
        Task<UserResponseDto> CreateUserAsync(CreateUserDto dto);
        Task<bool> UpdateUserAsync(int id, UpdateUserDto dto);
        Task<bool> SoftDeleteUserAsync(int id);
    }
}
