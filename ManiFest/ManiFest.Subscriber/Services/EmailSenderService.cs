using System.Net;
using System.Net.Mail;
using ManiFest.Subscriber.Interfaces;

namespace ManiFest.Subscriber.Services
{
    public class EmailSenderService : IEmailSenderService
    {
        private readonly string _gmailMail = "manifest.festival.info@gmail.com";
        private readonly string _gmailPass = "tdpo rukk xdqv eydw";

        public Task SendEmailAsync(string email, string subject, string message)
        {
            var client = new SmtpClient("smtp.gmail.com", 587)
            {
                EnableSsl = true,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(_gmailMail, _gmailPass)
            };

            return client.SendMailAsync(
                new MailMessage(from: _gmailMail,
                              to: email,
                              subject,
                              message
                              ));
        }
    }
}