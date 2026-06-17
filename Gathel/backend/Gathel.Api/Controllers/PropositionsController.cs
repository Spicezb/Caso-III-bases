using Gathel.Api.DTOs;
using Gathel.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Gathel.Api.Controllers;

[ApiController]
[Route("api/propositions")]
public class PropositionsController : ControllerBase
{
    private readonly PropositionService _propositionService;

    public PropositionsController(PropositionService propositionService)
    {
        _propositionService = propositionService;
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetActive()
    {
        var propositions = await _propositionService.GetActiveAsync();
        return Ok(propositions);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var proposition = await _propositionService.GetByIdAsync(id);

        if (proposition == null)
        {
            return NotFound(new { message = "Proposition not found" });
        }

        return Ok(proposition);
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreatePropositionRequest request)
    {
        await _propositionService.CreateAsync(request);

        return Ok(new
        {
            message = "Proposition created successfully"
        });
    }
}