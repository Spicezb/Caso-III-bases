using Gathel.Api.Data;
using Gathel.Api.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Gathel.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly GathelDbContext _context;

    public AuthController(GathelDbContext context)
    {
        _context = context;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Identifier))
        {
            return BadRequest(new
            {
                message = "Debe ingresar correo o nombre de usuario."
            });
        }

        var person = await _context.People
            .Where(p =>
                !p.IsDeleted &&
                p.IsActive &&
                (
                    p.Email == request.Identifier ||
                    p.Username == request.Identifier
                )
            )
            .Select(p => new
            {
                p.PersonId,
                p.Name,
                p.LastName,
                p.Username,
                p.Email,
                p.IsVerified,
                p.IsActive
            })
            .FirstOrDefaultAsync();

        if (person == null)
        {
            return Unauthorized(new
            {
                message = "Credenciales inválidas."
            });
        }

        return Ok(new
        {
            message = "Login successful",
            person
        });
    }
}