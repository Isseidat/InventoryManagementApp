using Inventory.Application.Interfaces.Interface_Repository;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Requires login
    public class ProfileController : ControllerBase
    {
        private readonly IUserRepository _userRepository;
        private readonly IEmailService _emailService;
        private readonly IMemoryCache _cache;

        public ProfileController(IUserRepository userRepository, IEmailService emailService, IMemoryCache cache)
        {
            _userRepository = userRepository;
            _emailService = emailService;
            _cache = cache;
        }

        private int GetCurrentUserId()
        {
            var idClaim = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (idClaim == null || !int.TryParse(idClaim.Value, out int userId))
            {
                throw new Exception("Unauthorized");
            }
            return userId;
        }

        [HttpGet]
        public async Task<IActionResult> GetMyProfile()
        {
            try
            {
                int userId = GetCurrentUserId();
                var user = await _userRepository.GetByIdAsync(userId);
                if (user == null) return NotFound();

                return Ok(new
                {
                    user.Id,
                    user.Username,
                    user.FullName,
                    user.Email,
                    user.PhoneNumber,
                    user.JobTitle,
                    Role = user.Role?.RoleName ?? "User"
                });
            }
            catch (Exception ex)
            {
                return Unauthorized(new { Message = ex.Message });
            }
        }

        [HttpPut]
        public async Task<IActionResult> UpdateBasicProfile([FromBody] UpdateBasicProfileDto dto)
        {
            try
            {
                int userId = GetCurrentUserId();
                var user = await _userRepository.GetByIdAsync(userId);
                if (user == null) return NotFound();

                user.FullName = dto.FullName ?? user.FullName;
                user.PhoneNumber = dto.PhoneNumber ?? user.PhoneNumber;

                await _userRepository.UpdateAsync(user);
                return Ok(new { Message = "Cập nhật thông tin thành công." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpPost("RequestOtp")]
        public async Task<IActionResult> RequestOtp()
        {
            try
            {
                int userId = GetCurrentUserId();
                var user = await _userRepository.GetByIdAsync(userId);
                if (user == null || string.IsNullOrEmpty(user.Email))
                {
                    return BadRequest(new { Message = "Tài khoản của bạn chưa có Email để nhận OTP." });
                }

                // Generate 6 digit OTP
                string otp = new Random().Next(100000, 999999).ToString();

                // Save to cache with 5 mins expiry. Key is "OTP_{userId}"
                _cache.Set($"OTP_{userId}", otp, TimeSpan.FromMinutes(5));

                // Send email
                string subject = "Mã xác thực OTP (Hệ thống Kho)";
                string body = $@"
                    <h2>Mã xác thực OTP của bạn</h2>
                    <p>Bạn vừa yêu cầu một mã OTP để thay đổi thông tin bảo mật.</p>
                    <p>Mã OTP của bạn là: <strong style='font-size:24px;color:blue;'>{otp}</strong></p>
                    <p>Mã này sẽ hết hạn trong 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai.</p>
                ";

                await _emailService.SendEmailAsync(user.Email, subject, body);

                return Ok(new { Message = $"Đã gửi mã OTP về email {user.Email}" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpPost("ChangePassword")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordWithOtpDto dto)
        {
            try
            {
                int userId = GetCurrentUserId();

                // Verify OTP
                if (!_cache.TryGetValue($"OTP_{userId}", out string? savedOtp) || savedOtp != dto.Otp)
                {
                    return BadRequest(new { Message = "Mã OTP không đúng hoặc đã hết hạn!" });
                }

                var user = await _userRepository.GetByIdAsync(userId);
                if (user == null) return NotFound();

                // Verify old password (simplistic check, assumes raw string for now or BCrypt if used)
                bool isMatch = BCrypt.Net.BCrypt.Verify(dto.OldPassword, user.PasswordHash);
                if (!isMatch)
                {
                    return BadRequest(new { Message = "Mật khẩu cũ không chính xác!" });
                }

                // Update password
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
                await _userRepository.UpdateAsync(user);

                // Clear OTP
                _cache.Remove($"OTP_{userId}");

                return Ok(new { Message = "Đổi mật khẩu thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }
    }

    public class UpdateBasicProfileDto
    {
        public string? FullName { get; set; }
        public string? PhoneNumber { get; set; }
    }

    public class ChangePasswordWithOtpDto
    {
        public string OldPassword { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
        public string Otp { get; set; } = string.Empty;
    }
}
