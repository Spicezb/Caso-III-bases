using Gathel.Api.DTOs;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Gathel.Api.Services;

public class PredictionService
{
    private readonly IConfiguration _configuration;

    public PredictionService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public async Task CreatePointPredictionAsync(CreatePointPredictionRequest request)
    {
        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spCreatePointPrediction", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@propositionId", request.PropositionId);
        command.Parameters.AddWithValue("@personId", request.PersonId);
        command.Parameters.AddWithValue("@predictionValue", request.PredictionValue);

        await command.ExecuteNonQueryAsync();
    }

    public async Task CreateMoneyPredictionAsync(CreateMoneyPredictionRequest request)
    {
        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spCreateMoneyPrediction", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@propositionId", request.PropositionId);
        command.Parameters.AddWithValue("@personId", request.PersonId);
        command.Parameters.AddWithValue("@predictionValue", request.PredictionValue);
        command.Parameters.AddWithValue("@moneyAmount", request.MoneyAmount);

        await command.ExecuteNonQueryAsync();
    }
}