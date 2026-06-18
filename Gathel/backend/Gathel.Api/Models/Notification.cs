namespace Gathel.Api.Models;

public class Notification
{
    public int NotificationId { get; set; }
    public int? NotificationTypeId { get; set; }
    public int? PersonId { get; set; }
    public string? Title { get; set; }
    public string? Message { get; set; }
    public bool IsRead { get; set; }
    public DateTime? ReadAt { get; set; }
    public int? ReferenceTypeId { get; set; }
    public int? ReferenceId { get; set; }
    public int? AuditPersonId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public bool IsDeleted { get; set; }
}