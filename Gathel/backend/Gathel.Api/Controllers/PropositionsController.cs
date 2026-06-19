using Gathel.Api.DTOs;
using Gathel.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;


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

    [HttpGet("voting")]
    public async Task<IActionResult> GetVoting()
    {
        var propositions = await _propositionService.GetVotingAsync();
        return Ok(propositions);
    }

    [HttpGet("voting/my-votes")]
    public async Task<IActionResult> GetMyVotingVotes([FromQuery] int personId)
    {
        var votes = await _propositionService.GetVotingVotesByPersonAsync(personId);
        return Ok(votes);
    }

    [HttpGet("pending-approval")]
    public async Task<IActionResult> GetPendingApproval([FromQuery] int targetPersonId)
    {
        var propositions = await _propositionService.GetPendingApprovalByTargetAsync(targetPersonId);
        return Ok(propositions);
    }

    [HttpPost("{id:int}/vote")]
    public async Task<IActionResult> VoteForCandidate(
        int id,
        VoteForCandidateRequest request
    )
    {
        try
        {
            await _propositionService.VoteForCandidateAsync(
                id,
                request.PersonId,
                request.VoteValue
            );

            return Ok(new
            {
                message = "Vote registered successfully"
            });
        }
        catch (SqlException ex) when (ex.Number >= 51100 && ex.Number <= 51199)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
    }

    [HttpPost("{id:int}/select-winner")]
    public async Task<IActionResult> SelectWinner(int id)
    {
        try
        {
            await _propositionService.SelectWinningPropositionAsync(id);

            return Ok(new
            {
                message = "Winning proposition selected successfully"
            });
        }
        catch (SqlException ex) when (ex.Number >= 51200 && ex.Number <= 51299)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
    }

    [HttpPost("{id:int}/accept")]
    public async Task<IActionResult> Accept(
        int id,
        AcceptPropositionRequest request
    )
    {
        await _propositionService.AcceptWinningPropositionAsync(
            id,
            request.TargetPersonId,
            request.StartPredictionDateTime,
            request.EndPredictionDateTime
        );

        return Ok(new
        {
            message = "Proposition accepted successfully"
        });
    }

    [HttpPost("{id:int}/reject")]
    public async Task<IActionResult> Reject(
        int id,
        RejectPropositionRequest request
    )
    {
        await _propositionService.RejectWinningPropositionAsync(
            id,
            request.TargetPersonId
        );

        return Ok(new
        {
            message = "Proposition rejected successfully"
        });
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
        var propositionId = await _propositionService.CreateAsync(request);

        return Ok(new
        {
            message = "Proposition created successfully",
            propositionId,
            proposition = propositionId.HasValue
                ? new
                {
                    propositionId = propositionId.Value
                }
                : null
        });
    }
}