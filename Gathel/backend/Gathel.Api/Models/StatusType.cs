namespace Gathel.Api.Models;

public class StatusType
{
    public int StatusTypeId { get; set; }
    public string? Name { get; set; }
    public string? Description { get; set; }

    public bool IsDeleted { get; set; }
}