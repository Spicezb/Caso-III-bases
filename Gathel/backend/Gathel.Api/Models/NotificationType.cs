namespace Gathel.Api.Models;

public class NotificationType
{
    public int NotificationTypeId { get; set; }
    public string? Name { get; set; }
    public string? Description { get; set; }
    public int? AuditPersonId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public bool IsDeleted { get; set; }
}