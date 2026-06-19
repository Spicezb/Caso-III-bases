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
                && st.Name == "Active"
                && p.StartPredictionDateTime <= DateTime.Now
                && p.EndPredictionDateTime > DateTime.Now
            orderby p.EndPredictionDateTime ascending
            select new
            {
                p.PropositionId,
                ParentProposition = p.ParentProposition,
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

        return await query.Cast<object>().ToListAsync();
    }

    public async Task<List<VotingPropositionGroupResponse>> GetVotingAsync()
    {
        var parentRows = await (
            from p in _context.Propositions
            join st in _context.StatusTypes
                on p.StatusTypesId equals st.StatusTypeId
            where !p.IsDeleted
                && !st.IsDeleted
                && st.Name == "Voting"
                && p.ParentProposition == null
            orderby p.CreatedAt descending
            select new VotingPropositionGroupResponse
            {
                PropositionId = p.PropositionId,
                Title = p.Title ?? "",
                Description = p.Description,
                CreatorPersonId = p.CreatorPersonId ?? 0,
                TargetPersonId = p.TargetPersonId ?? 0,
                TargetSocialAccountId = p.TargetSocialAccountId,
                StartPredictionDateTime = p.StartPredictionDateTime,
                EndPredictionDateTime = p.EndPredictionDateTime,
                Status = st.Name ?? ""
            }
        ).ToListAsync();

        var parentIds = parentRows
            .Select(parent => parent.PropositionId)
            .ToList();

        if (parentIds.Count == 0)
        {
            return parentRows;
        }

        var candidateRows = await (
            from child in _context.Propositions
            join st in _context.StatusTypes
                on child.StatusTypesId equals st.StatusTypeId
            where !child.IsDeleted
                && !st.IsDeleted
                && st.Name == "Voting"
                && child.ParentProposition != null
                && parentIds.Contains(child.ParentProposition.Value)
            orderby child.CreatedAt ascending
            select new VotingCandidateResponse
            {
                PropositionId = child.PropositionId,
                ParentPropositionId = child.ParentProposition!.Value,
                Title = child.Title ?? "",
                Description = child.Description,
                CreatorPersonId = child.CreatorPersonId ?? 0,
                TargetPersonId = child.TargetPersonId ?? 0,
                TargetSocialAccountId = child.TargetSocialAccountId,
                StartPredictionDateTime = child.StartPredictionDateTime,
                EndPredictionDateTime = child.EndPredictionDateTime,
                Status = st.Name ?? ""
            }
        ).ToListAsync();

        foreach (var parent in parentRows)
        {
            parent.Candidates = candidateRows
                .Where(candidate => candidate.ParentPropositionId == parent.PropositionId)
                .ToList();
        }

        return parentRows;
    }

    public async Task<List<object>> GetPendingApprovalByTargetAsync(int targetPersonId)
    {
        var query =
            from p in _context.Propositions
            join st in _context.StatusTypes
                on p.StatusTypesId equals st.StatusTypeId
            where !p.IsDeleted
                && !st.IsDeleted
                && st.Name == "PendingApproval"
                && p.TargetPersonId == targetPersonId
            orderby p.CreatedAt descending
            select new
            {
                p.PropositionId,
                ParentProposition = p.ParentProposition,
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
                  && !st.IsDeleted
            select new
            {
                p.PropositionId,
                ParentProposition = p.ParentProposition,
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

    public async Task<int?> CreateAsync(CreatePropositionRequest request)
    {
        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spCreateProposition", connection);
        command.CommandType = CommandType.StoredProcedure;

        var parentProposition =
            request.ParentProposition ?? request.ParentPropositionId;

        command.Parameters.AddWithValue("@creatorPersonId", request.CreatorPersonId);
        command.Parameters.AddWithValue("@targetPersonId", request.TargetPersonId);

        command.Parameters.AddWithValue(
            "@targetSocialAccountId",
            request.TargetSocialAccountId.HasValue
                ? (object)request.TargetSocialAccountId.Value
                : DBNull.Value
        );

        command.Parameters.AddWithValue("@title", request.Title);

        command.Parameters.AddWithValue(
            "@description",
            string.IsNullOrWhiteSpace(request.Description)
                ? DBNull.Value
                : request.Description
        );

        command.Parameters.AddWithValue("@startPredictionDateTime", request.StartPredictionDateTime);
        command.Parameters.AddWithValue("@endPredictionDateTime", request.EndPredictionDateTime);

        command.Parameters.AddWithValue(
            "@minimumEntryPointsAmount",
            request.MinimumEntryPointsAmount.HasValue
                ? (object)request.MinimumEntryPointsAmount.Value
                : DBNull.Value
        );

        command.Parameters.AddWithValue(
            "@winningProfitPercentage",
            request.WinningProfitPercentage.HasValue
                ? (object)request.WinningProfitPercentage.Value
                : DBNull.Value
        );

        command.Parameters.AddWithValue(
            "@parentProposition",
            parentProposition.HasValue
                ? (object)parentProposition.Value
                : DBNull.Value
        );
        int? createdPropositionId = null;

        await using (var reader = await command.ExecuteReaderAsync())
        {
            while (await reader.ReadAsync())
            {
                for (var i = 0; i < reader.FieldCount; i++)
                {
                    var columnName = reader.GetName(i);

                    if (
                        string.Equals(columnName, "propositionId", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(columnName, "PropositionId", StringComparison.OrdinalIgnoreCase)
                    )
                    {
                        if (!reader.IsDBNull(i))
                        {
                            createdPropositionId = Convert.ToInt32(reader.GetValue(i));
                        }
                    }
                }
            }
        }

        if (createdPropositionId.HasValue)
        {
            return createdPropositionId.Value;
        }

        await using var fallbackCommand = new SqlCommand(
            @"
                SELECT TOP 1 propositionId
                FROM propositions
                WHERE creatorPersonId = @creatorPersonId
                  AND targetPersonId = @targetPersonId
                  AND title = @title
                  AND isDeleted = 0
                  AND (
                        (@parentProposition IS NULL AND parentproposition IS NULL)
                        OR parentproposition = @parentProposition
                  )
                ORDER BY createdAt DESC, propositionId DESC;
            ",
            connection
        );

        fallbackCommand.Parameters.AddWithValue("@creatorPersonId", request.CreatorPersonId);
        fallbackCommand.Parameters.AddWithValue("@targetPersonId", request.TargetPersonId);
        fallbackCommand.Parameters.AddWithValue("@title", request.Title);

        fallbackCommand.Parameters.AddWithValue(
            "@parentProposition",
            parentProposition.HasValue
                ? (object)parentProposition.Value
                : DBNull.Value
        );

        var fallbackResult = await fallbackCommand.ExecuteScalarAsync();

        if (fallbackResult == null || fallbackResult == DBNull.Value)
        {
            return null;
        }

        return Convert.ToInt32(fallbackResult);
    }

    public async Task VoteForCandidateAsync(int propositionId, int personId, bool voteValue)
    {
        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spVoteForCandidateProposition", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@propositionId", propositionId);
        command.Parameters.AddWithValue("@personId", personId);
        command.Parameters.AddWithValue("@voteValue", voteValue);

        await command.ExecuteNonQueryAsync();
    }

    public async Task SelectWinningPropositionAsync(int parentPropositionId)
    {
        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spSelectWinningPropositionAfterVoting", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@parentPropositionId", parentPropositionId);

        await command.ExecuteNonQueryAsync();
    }

    public async Task AcceptWinningPropositionAsync(
        int propositionId,
        int targetPersonId,
        DateTime startPredictionDateTime,
        DateTime endPredictionDateTime
    )
    {
        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spAcceptWinningProposition", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@propositionId", propositionId);
        command.Parameters.AddWithValue("@targetPersonId", targetPersonId);
        command.Parameters.AddWithValue("@startPredictionDateTime", startPredictionDateTime);
        command.Parameters.AddWithValue("@endPredictionDateTime", endPredictionDateTime);

        await command.ExecuteNonQueryAsync();
    }

    public async Task RejectWinningPropositionAsync(int propositionId, int targetPersonId)
    {
        var connectionString = _configuration.GetConnectionString("GathelDb");

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand("spRejectWinningProposition", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@propositionId", propositionId);
        command.Parameters.AddWithValue("@targetPersonId", targetPersonId);

        await command.ExecuteNonQueryAsync();
    }

    public async Task<List<VotingVoteResponse>> GetVotingVotesByPersonAsync(int personId)
    {
        var votes = await (
            from pv in _context.PropositionVotes
            join child in _context.Propositions
                on pv.PropositionId equals child.PropositionId
            where pv.PersonId == personId
                && !pv.IsDeleted
                && pv.VoteValue == true
                && !child.IsDeleted
                && child.ParentProposition != null
            select new VotingVoteResponse
            {
                ParentPropositionId = child.ParentProposition!.Value,
                CandidatePropositionId = child.PropositionId
            }
        ).ToListAsync();

        return votes;
    }
}