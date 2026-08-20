using System;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
using Inventory.Application.Interfaces.Interface_Service;
using Microsoft.Extensions.Configuration;

namespace Inventory.Application.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _config;

        public EmailService(IConfiguration config)
        {
            _config = config;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            var host = _config["EmailSettings:Host"] ?? "smtp.gmail.com";
            var portStr = _config["EmailSettings:Port"] ?? "587";
            var username = _config["EmailSettings:Username"];
            var password = _config["EmailSettings:Password"]; // App Password

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                // Fallback to console if not configured
                Console.WriteLine("------------------------------------------");
                Console.WriteLine($"[MOCK EMAIL] TO: {toEmail}");
                Console.WriteLine($"[MOCK EMAIL] SUBJECT: {subject}");
                Console.WriteLine($"[MOCK EMAIL] BODY: {body}");
                Console.WriteLine("------------------------------------------");
                return;
            }

            int port = int.Parse(portStr);

            using var smtp = new SmtpClient(host, port)
            {
                EnableSsl = true,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(username, password)
            };

            using var mailMessage = new MailMessage
            {
                From = new MailAddress(username, "Inventory App"),
                Subject = subject,
                Body = body,
                IsBodyHtml = true,
            };
            mailMessage.To.Add(toEmail);

            try
            {
                await smtp.SendMailAsync(mailMessage);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EMAIL ERROR] Failed to send email to {toEmail}: {ex.Message}");
                throw new Exception("Không thể gửi email OTP, vui lòng thử lại sau.");
            }
        }
    }
}
