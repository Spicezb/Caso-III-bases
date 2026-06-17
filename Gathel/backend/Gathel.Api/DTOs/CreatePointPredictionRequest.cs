namespace Gathel.Api.DTOs;

public class CreatePointPredictionRequest
{
    public int PropositionId { get; set; }
    public int PersonId { get; set; }
    public bool PredictionValue { get; set; }
}