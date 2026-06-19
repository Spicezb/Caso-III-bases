namespace Gathel.Api.DTOs;

public class VotingPropositionGroupResponse
{
    public int PropositionId { get; set; }
    public string Title { get; set; } = "";
    public string? Description { get; set; }
    public int CreatorPersonId { get; set; }
    public int TargetPersonId { get; set; }
    public int? TargetSocialAccountId { get; set; }
    public DateTime StartPredictionDateTime { get; set; }
    public DateTime EndPredictionDateTime { get; set; }
    public string Status { get; set; } = "";
    public List<VotingCandidateResponse> Candidates { get; set; } = new();
}

public class VotingCandidateResponse
{
    public int PropositionId { get; set; }
    public int ParentPropositionId { get; set; }
    public string Title { get; set; } = "";
    public string? Description { get; set; }
    public int CreatorPersonId { get; set; }
    public int TargetPersonId { get; set; }
    public int? TargetSocialAccountId { get; set; }
    public DateTime StartPredictionDateTime { get; set; }
    public DateTime EndPredictionDateTime { get; set; }
    public string Status { get; set; } = "";
}