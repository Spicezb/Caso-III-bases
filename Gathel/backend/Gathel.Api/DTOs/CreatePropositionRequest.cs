namespace Gathel.Api.DTOs;

public class CreatePropositionRequest
{
    public int CreatorPersonId { get; set; }
    public int TargetPersonId { get; set; }
    public int? TargetSocialAccountId { get; set; }

    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }

    public DateTime StartPredictionDateTime { get; set; }
    public DateTime EndPredictionDateTime { get; set; }

    public decimal? MinimumEntryPointsAmount { get; set; }
    public decimal? WinningProfitPercentage { get; set; }
}