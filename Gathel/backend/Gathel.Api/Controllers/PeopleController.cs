using Gathel.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Gathel.Api.Controllers;

[ApiController]
[Route("api/people")]
public class PeopleController : ControllerBase
{
    private readonly PeopleService _peopleService;

    public PeopleController(PeopleService peopleService)
    {
        _peopleService = peopleService;
    }

    [HttpGet("me")]
    public async Task<IActionResult> GetMe([FromQuery] int personId = 1)
    {
        var person = await _peopleService.GetMeAsync(personId);

        if (person == null)
        {
            return NotFound(new { message = "Person not found" });
        }

        return Ok(person);
    }
}