using Inventory.Application.DTOs.Auth;
using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Inventory.Domain.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using BCrypt.Net;

namespace Inventory.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserRepository _userRepo;
        private readonly IConfiguration _config;

        public AuthService(IUserRepository userRepo, IConfiguration config)
        {
            _userRepo = userRepo;
            _config = config;
        }

        public async Task<TokenResponseDto> LoginAsync(LoginDto dto)
        {
            var user = await _userRepo.GetByUsernameAsync(dto.Username);
            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            {
                throw new Exception("Tài khoản hoặc mật khẩu không chính xác.");
            }

            // Tạo Claims
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.Role?.RoleName ?? "User")
            };

            // Sinh Token
            var jwtSettings = _config.GetSection("JwtSettings");
            var secretKey = jwtSettings["SecretKey"];
            if (string.IsNullOrEmpty(secretKey)) throw new Exception("Thiếu SecretKey trong appsettings");

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var expiry = DateTime.Now.AddMinutes(Convert.ToDouble(jwtSettings["ExpiryMinutes"]));

            var token = new JwtSecurityToken(
                issuer: jwtSettings["Issuer"],
                audience: jwtSettings["Audience"],
                claims: claims,
                expires: expiry,
                signingCredentials: creds
            );

            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

            return new TokenResponseDto
            {
                Token = tokenString,
                FullName = user.FullName,
                RoleName = user.Role?.RoleName ?? "User",
                JobTitle = user.JobTitle
            };
        }

        public async Task<bool> RegisterAsync(RegisterDto dto)
        {
            var existingUser = await _userRepo.GetByUsernameAsync(dto.Username);
            if (existingUser != null) throw new Exception("Tên đăng nhập đã tồn tại.");

            var role = await _userRepo.GetRoleByIdAsync(dto.RoleId);
            if (role == null) throw new Exception("Role không tồn tại.");

            var user = new User
            {
                Username = dto.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                FullName = dto.FullName,
                Email = dto.Email,
                JobTitle = dto.JobTitle,
                RoleId = dto.RoleId
            };

            await _userRepo.CreateAsync(user);
            return true;
        }
    }
}
