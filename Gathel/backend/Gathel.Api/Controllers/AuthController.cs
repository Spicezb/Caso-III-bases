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
    private readonly IConfiguration _configuration;

    public AuthController(GathelDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
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

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name) ||
            string.IsNullOrWhiteSpace(request.Username) ||
            string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new
            {
                message = "Debe completar todos los campos obligatorios."
            });
        }

        if (request.Password.Length < 8)
        {
            return BadRequest(new
            {
                message = "La contraseña debe tener al menos 8 caracteres."
            });
        }

        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spRegisterPerson", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@name", request.Name);
        command.Parameters.AddWithValue("@lastName", request.LastName);
        command.Parameters.AddWithValue("@username", request.Username);
        command.Parameters.AddWithValue("@email", request.Email);
        command.Parameters.AddWithValue("@password", request.Password);

        try
        {
            await using var reader = await command.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                return Ok(new
                {
                    message = "Register successful",
                    person = new
                    {
                        personId = reader.GetInt32(reader.GetOrdinal("personId")),
                        name = reader.GetString(reader.GetOrdinal("name")),
                        lastName = reader.GetString(reader.GetOrdinal("lastName")),
                        username = reader.GetString(reader.GetOrdinal("username")),
                        email = reader.GetString(reader.GetOrdinal("email"))
                    }
                });
            }

            return Ok(new
            {
                message = "Register successful"
            });
        }
        catch (SqlException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
    }
}