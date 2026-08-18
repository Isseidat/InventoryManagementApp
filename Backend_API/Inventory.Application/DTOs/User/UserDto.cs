namespace Inventory.Application.DTOs.User
{
    public class UserResponseDto
    {
        public int Id { get; set; }
        public string Username { get; set; } = null!;
        public string FullName { get; set; } = null!;
        public string? Email { get; set; }
        public string? JobTitle { get; set; }
        public string? RoleName { get; set; }
        public int? RoleId { get; set; }
    }

    public class CreateUserDto
    {
        public string Username { get; set; } = null!;
        public string Password { get; set; } = null!;
        public string FullName { get; set; } = null!;
        public string? Email { get; set; }
        public string? JobTitle { get; set; }
        public int RoleId { get; set; }
    }

    public class UpdateUserDto
    {
        public string FullName { get; set; } = null!;
        public string? Email { get; set; }
        public string? JobTitle { get; set; }
        public int RoleId { get; set; }
        public string? NewPassword { get; set; }
    }
}
