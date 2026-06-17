namespace Gathel.Api.Models;

public class Prediction
{
    public int PredictionId { get; set; }
    public int? StatusTypesId { get; set; }
    public int? PropositionId { get; set; }
    public int? PersonId { get; set; }

    public bool? PredictionValue { get; set; }

    public decimal? PointsAmount { get; set; }
    public decimal? MoneyAmount { get; set; }

    public int? CurrencyId { get; set; }
    public int? ExchangeRateId { get; set; }

    public DateTime PredictionDateTime { get; set; }

    public bool IsWinner { get; set; }
    public bool IsDeleted { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}