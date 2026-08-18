using Inventory.Application.DTOs.Auth;
using System.Threading.Tasks;

namespace Inventory.Application.Interfaces.Interface_Service
{
    public interface IAuthService
    {
        Task<TokenResponseDto> LoginAsync(LoginDto dto);
        Task<bool> RegisterAsync(RegisterDto dto);
    }
}
