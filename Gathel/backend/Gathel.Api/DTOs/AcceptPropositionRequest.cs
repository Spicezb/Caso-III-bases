namespace Gathel.Api.DTOs;

public class AcceptPropositionRequest
{
    public int TargetPersonId { get; set; }
    public DateTime StartPredictionDateTime { get; set; }
    public DateTime EndPredictionDateTime { get; set; }
}