namespace Gathel.Api.Models;

public class PropositionVote
{
    public int PropositionVoteId { get; set; }
    public int PropositionId { get; set; }
    public int PersonId { get; set; }
    public bool? VoteValue { get; set; }
    public DateTime VoteDateTime { get; set; }
    public bool IsDeleted { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}