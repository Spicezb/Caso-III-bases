using Gathel.Api.Data;
using Gathel.Api.DTOs;
using Gathel.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Gathel.Api.Controllers;

[ApiController]
[Route("api/predictions")]
public class PredictionsController : ControllerBase
{
    private readonly PredictionService _predictionService;
    private readonly GathelDbContext _context;

    public PredictionsController(
        PredictionService predictionService,
        GathelDbContext context
    )
    {
        _predictionService = predictionService;
        _context = context;
    }

    [HttpPost("points")]
    public async Task<IActionResult> CreatePointPrediction(CreatePointPredictionRequest request)
    {
        await _predictionService.CreatePointPredictionAsync(request);

        return Ok(new
        {
            message = "Point prediction created successfully"
        });
    }

    [HttpPost("money")]
    public async Task<IActionResult> CreateMoneyPrediction(CreateMoneyPredictionRequest request)
    {
        await _predictionService.CreateMoneyPredictionAsync(request);

        return Ok(new
        {
            message = "Money prediction created successfully"
        });
    }

    [HttpGet("proposition/{propositionId:int}")]
    public async Task<IActionResult> GetPredictionsByProposition(int propositionId)
    {
        var predictions = await (
            from pr in _context.Predictions
            join pe in _context.People
                on pr.PersonId equals pe.PersonId
            where pr.PropositionId == propositionId
                  && !pr.IsDeleted
                  && !pe.IsDeleted
            orderby pr.PredictionDateTime descending
            select new
            {
                predictionId = pr.PredictionId,
                propositionId = pr.PropositionId,
                personId = pr.PersonId,
                user = ((pe.Name ?? "") + " " + (pe.LastName ?? "")).Trim(),
                handle = "@" + pe.Username,
                predictionValue = pr.PredictionValue ?? false,
                pointsAmount = pr.PointsAmount,
                moneyAmount = pr.MoneyAmount,
                predictionDateTime = pr.PredictionDateTime
            }
        ).ToListAsync();

        return Ok(predictions);
    }

    [HttpGet("person/{personId:int}")]
    public async Task<IActionResult> GetPredictionsByPerson(int personId)
    {
        var predictions = await (
            from pr in _context.Predictions
            join pe in _context.People
                on pr.PersonId equals pe.PersonId
            join prop in _context.Propositions
                on pr.PropositionId equals prop.PropositionId
            where pr.PersonId == personId
                && !pr.IsDeleted
                && !pe.IsDeleted
                && !prop.IsDeleted
            orderby pr.PredictionDateTime descending
            select new
            {
                predictionId = pr.PredictionId,
                propositionId = pr.PropositionId,
                personId = pr.PersonId,
                user = ((pe.Name ?? "") + " " + (pe.LastName ?? "")).Trim(),
                handle = "@" + pe.Username,
                predictionValue = pr.PredictionValue ?? false,
                pointsAmount = pr.PointsAmount,
                moneyAmount = pr.MoneyAmount,
                predictionDateTime = pr.PredictionDateTime,
                propositionTitle = prop.Title,
                propositionDescription = prop.Description,
                propositionEndDateTime = prop.EndPredictionDateTime,
                isWinner = pr.IsWinner
            }
        ).ToListAsync();

        return Ok(predictions);
    }
}