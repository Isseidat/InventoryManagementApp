namespace Inventory.Application.DTOs.Auth
{
    public class LoginDto
    {
        public string Username { get; set; } = null!;
        public string Password { get; set; } = null!;
    }

    public class RegisterDto
    {
        public string Username { get; set; } = null!;
        public string Password { get; set; } = null!;
        public string FullName { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string? JobTitle { get; set; }
        public int RoleId { get; set; }
    }

    public class TokenResponseDto
    {
        public string Token { get; set; } = null!;
        public string FullName { get; set; } = null!;
        public string RoleName { get; set; } = null!;
        public string? JobTitle { get; set; }
    }
}
