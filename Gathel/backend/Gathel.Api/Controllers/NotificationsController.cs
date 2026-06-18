using Gathel.Api.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Gathel.Api.Controllers;

[ApiController]
[Route("api/notifications")]
public class NotificationsController : ControllerBase
{
    private readonly GathelDbContext _context;

    public NotificationsController(GathelDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetMyNotifications([FromQuery] int personId)
    {
        var notifications = await (
            from n in _context.Notifications
            join nt in _context.NotificationTypes
                on n.NotificationTypeId equals nt.NotificationTypeId
            where n.PersonId == personId
                  && !n.IsDeleted
                  && !nt.IsDeleted
            orderby n.CreatedAt descending
            select new
            {
                notificationId = n.NotificationId,
                notificationType = nt.Name,
                title = n.Title,
                body = n.Message,
                createdAt = n.CreatedAt,
                isRead = n.IsRead
            }
        ).ToListAsync();

        return Ok(notifications);
    }

    [HttpPost("{notificationId:int}/read")]
    public async Task<IActionResult> MarkNotificationRead(int notificationId)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n =>
                n.NotificationId == notificationId &&
                !n.IsDeleted
            );

        if (notification == null)
        {
            return NotFound(new
            {
                message = "No se encontró la notificación."
            });
        }

        notification.IsRead = true;
        notification.ReadAt = DateTime.Now;
        notification.UpdatedAt = DateTime.Now;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Notification marked as read"
        });
    }

    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllNotificationsRead([FromQuery] int personId)
    {
        var notifications = await _context.Notifications
            .Where(n =>
                n.PersonId == personId &&
                !n.IsDeleted &&
                !n.IsRead
            )
            .ToListAsync();

        foreach (var notification in notifications)
        {
            notification.IsRead = true;
            notification.ReadAt = DateTime.Now;
            notification.UpdatedAt = DateTime.Now;
        }

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "All notifications marked as read"
        });
    }
}