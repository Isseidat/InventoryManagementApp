using Inventory.Application.DTOs.Auth;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Inventory.Presentation.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("Login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            try
            {
                var result = await _authService.LoginAsync(dto);
                return Ok(new { status = true, data = result });
            }
            catch (Exception ex)
            {
                return Unauthorized(new { status = false, message = ex.Message });
            }
        }

        [HttpPost("Register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            try
            {
                await _authService.RegisterAsync(dto);
                return Ok(new { status = true, message = "Đăng ký tài khoản thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, message = ex.Message });
            }
        }
    
        [Microsoft.AspNetCore.Mvc.HttpPost("ForgotPassword")]
        public async Task<Microsoft.AspNetCore.Mvc.IActionResult> ForgotPassword([Microsoft.AspNetCore.Mvc.FromBody] ForgotPasswordRequestDto dto)
        {
            try
            {
                await _authService.RequestPasswordResetAsync(dto);
                return Ok(new { status = true, message = "OTP sent." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, message = ex.Message });
            }
        }

        [Microsoft.AspNetCore.Mvc.HttpPost("ResetPassword")]
        public async Task<Microsoft.AspNetCore.Mvc.IActionResult> ResetPassword([Microsoft.AspNetCore.Mvc.FromBody] ResetPasswordDto dto)
        {
            try
            {
                await _authService.ResetPasswordAsync(dto);
                return Ok(new { status = true, message = "Password reset successful." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, message = ex.Message });
            }
        }
    }

}
