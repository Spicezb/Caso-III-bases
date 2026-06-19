namespace Gathel.Api.DTOs;

public class VoteForCandidateRequest
{
    public int PersonId { get; set; }
    public bool VoteValue { get; set; } = true;
}