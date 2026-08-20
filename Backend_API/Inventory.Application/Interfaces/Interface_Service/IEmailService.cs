namespace Inventory.Application.Interfaces.Interface_Service
{
    using System.Threading.Tasks;

    public interface IEmailService
    {
        Task SendEmailAsync(string toEmail, string subject, string body);
    }
}
