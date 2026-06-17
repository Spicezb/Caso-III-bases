namespace Gathel.Api.DTOs;

public class CreateMoneyPredictionRequest
{
    public int PropositionId { get; set; }
    public int PersonId { get; set; }
    public bool PredictionValue { get; set; }
    public decimal MoneyAmount { get; set; }
}