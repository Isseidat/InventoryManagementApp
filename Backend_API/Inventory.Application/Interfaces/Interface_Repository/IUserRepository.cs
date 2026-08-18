using Inventory.Domain.Entities;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Repository
{
    public interface IUserRepository
    {
        Task<User?> GetByUsernameAsync(string username);
        Task<User?> GetByIdAsync(int id);
        Task<IEnumerable<User>> GetAllUsersAsync();
        Task<User> CreateAsync(User user);
        Task UpdateAsync(User user);
        Task<Role?> GetRoleByIdAsync(int id);
    }
}
