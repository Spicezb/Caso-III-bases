namespace Gathel.Api.Models;

public class Person
{
    public int PersonId { get; set; }
    public int? PeopleTypeId { get; set; }

    public string? Name { get; set; }
    public string? LastName { get; set; }
    public string? Identification { get; set; }
    public string? Phone { get; set; }
    public string? Email { get; set; }
    public string? Username { get; set; }
    public string? Biography { get; set; }

    public bool IsVerified { get; set; }
    public bool IsActive { get; set; }
    public bool IsDeleted { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}