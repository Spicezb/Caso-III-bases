using Gathel.Api.DTOs;
using Gathel.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Gathel.Api.Controllers;

[ApiController]
[Route("api/predictions")]
public class PredictionsController : ControllerBase
{
    private readonly PredictionService _predictionService;

    public PredictionsController(PredictionService predictionService)
    {
        _predictionService = predictionService;
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
}