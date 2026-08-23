using Microsoft.Extensions.Caching.Memory;
using System.Linq;
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
        private readonly IEmailService _emailService;
        private readonly IMemoryCache _cache;

        public AuthService(IUserRepository userRepo, IConfiguration config, IEmailService emailService, IMemoryCache cache)
        {
            _userRepo = userRepo;
            _config = config;
            _emailService = emailService;
            _cache = cache;
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
    
        public async Task RequestPasswordResetAsync(ForgotPasswordRequestDto dto)
        {
            var users = await _userRepo.GetAllUsersAsync();
            var user = users.FirstOrDefault(u => u.Email == dto.Email);
            if (user == null)
            {
                throw new Exception("Không tìm thấy tài khoản nào liên kết với Email này.");
            }

            var otp = new Random().Next(100000, 999999).ToString();
            _cache.Set($"RESET_OTP_{dto.Email}", otp, TimeSpan.FromMinutes(5));

            var subject = "Yêu cầu khôi phục mật khẩu (Inventory App)";
            var body = $@"
                <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 10px;'>
                    <h1 style='color: #4f46e5; text-align: center;'>Khôi phục mật khẩu</h1>
                    <p style='font-size: 16px; color: #333;'>Chào bạn,</p>
                    <p style='font-size: 16px; color: #333;'>Bạn vừa yêu cầu khôi phục mật khẩu cho tài khoản InventoryPro.</p>
                    <p style='font-size: 16px; color: #333;'>Mã OTP của bạn là:</p>
                    <div style='text-align: center; margin: 30px 0;'>
                        <strong style='font-size: 32px; color: #ef4444; letter-spacing: 5px; padding: 10px 20px; background-color: #fee2e2; border-radius: 8px;'>{otp}</strong>
                    </div>
                    <p style='font-size: 14px; color: #64748b; text-align: center;'>Mã này sẽ hết hạn sau 5 phút.</p>
                </div>";

            await _emailService.SendEmailAsync(user.Email, subject, body);
        }

        public async Task ResetPasswordAsync(ResetPasswordDto dto)
        {
            if (!_cache.TryGetValue($"RESET_OTP_{dto.Email}", out string? savedOtp) || savedOtp != dto.Otp)
            {
                throw new Exception("Mã OTP không đúng hoặc đã hết hạn!");
            }

            var users = await _userRepo.GetAllUsersAsync();
            var user = users.FirstOrDefault(u => u.Email == dto.Email);
            if (user == null) throw new Exception("Tài khoản không tồn tại.");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            await _userRepo.UpdateAsync(user);

            _cache.Remove($"RESET_OTP_{dto.Email}");
        }
    }
}
