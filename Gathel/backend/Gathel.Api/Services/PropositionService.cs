using Gathel.Api.Data;
using Gathel.Api.DTOs;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace Gathel.Api.Services;

public class PropositionService
{
    private readonly GathelDbContext _context;
    private readonly IConfiguration _configuration;

    public PropositionService(GathelDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<List<object>> GetActiveAsync()
    {
        var query =
            from p in _context.Propositions
            join st in _context.StatusTypes
                on p.StatusTypesId equals st.StatusTypeId
            where !p.IsDeleted
                  && !st.IsDeleted
                  && (
                        st.Name == "Active"
                        || st.Name == "Activa"
                        || st.Name == "ACTIVE"
                        || st.Name == "Abierta"
                     )
            orderby p.CreatedAt descending
            select new
            {
                p.PropositionId,
                p.Title,
                p.Description,
                p.CreatorPersonId,
                p.TargetPersonId,
                p.StartPredictionDateTime,
                p.EndPredictionDateTime,
                p.MinimumEntryPointsAmount,
                p.WinningProfitPercentage,
                Status = st.Name
            };

        return await query.Cast<object>().ToListAsync();
    }

    public async Task<object?> GetByIdAsync(int propositionId)
    {
        var query =
            from p in _context.Propositions
            join st in _context.StatusTypes
                on p.StatusTypesId equals st.StatusTypeId
            where p.PropositionId == propositionId
                  && !p.IsDeleted
            select new
            {
                p.PropositionId,
                p.Title,
                p.Description,
                p.CreatorPersonId,
                p.TargetPersonId,
                p.TargetSocialAccountId,
                p.StartPredictionDateTime,
                p.EndPredictionDateTime,
                p.MinimumEntryPointsAmount,
                p.WinningProfitPercentage,
                p.WinningOption,
                Status = st.Name
            };

        return await query.FirstOrDefaultAsync();
    }

    public async Task CreateAsync(CreatePropositionRequest request)
    {
        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spCreateProposition", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@creatorPersonId", request.CreatorPersonId);
        command.Parameters.AddWithValue("@targetPersonId", request.TargetPersonId);
        command.Parameters.AddWithValue("@targetSocialAccountId", (object?)request.TargetSocialAccountId ?? DBNull.Value);
        command.Parameters.AddWithValue("@title", request.Title);
        command.Parameters.AddWithValue("@description", (object?)request.Description ?? DBNull.Value);
        command.Parameters.AddWithValue("@startPredictionDateTime", request.StartPredictionDateTime);
        command.Parameters.AddWithValue("@endPredictionDateTime", request.EndPredictionDateTime);
        command.Parameters.AddWithValue("@minimumEntryPointsAmount", (object?)request.MinimumEntryPointsAmount ?? DBNull.Value);
        command.Parameters.AddWithValue("@winningProfitPercentage", (object?)request.WinningProfitPercentage ?? DBNull.Value);

        await command.ExecuteNonQueryAsync();
    }
}