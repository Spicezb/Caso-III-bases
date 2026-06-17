namespace Gathel.Api.Models;

public class Proposition
{
    public int PropositionId { get; set; }
    public int? ParentProposition { get; set; }
    public int? StatusTypesId { get; set; }
    public int? CreatorPersonId { get; set; }
    public int? TargetPersonId { get; set; }
    public int? TargetSocialAccountId { get; set; }

    public string? Title { get; set; }
    public string? Description { get; set; }

    public DateTime StartPredictionDateTime { get; set; }
    public DateTime EndPredictionDateTime { get; set; }

    public bool? WinningOption { get; set; }
    public decimal? MinimumEntryPointsAmount { get; set; }
    public decimal? WinningProfitPercentage { get; set; }

    public bool IsPublic { get; set; }
    public bool IsDeleted { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}