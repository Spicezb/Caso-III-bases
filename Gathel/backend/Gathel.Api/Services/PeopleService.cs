using Gathel.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace Gathel.Api.Services;

public class PeopleService
{
    private readonly GathelDbContext _context;

    public PeopleService(GathelDbContext context)
    {
        _context = context;
    }

    public async Task<object?> GetMeAsync(int personId)
    {
        var person = await _context.People
            .Where(p => p.PersonId == personId && !p.IsDeleted)
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
            return null;
        }

        var wallet = await _context.Wallets
            .Where(w => w.PersonId == personId && !w.IsDeleted)
            .FirstOrDefaultAsync();

        decimal pointsBalance = 0;

        if (wallet != null)
        {
            var lastBalance = await _context.WalletBalances
                .Where(b => b.WalletId == wallet.WalletId && !b.IsDeleted)
                .OrderByDescending(b => b.CalculatedAt)
                .ThenByDescending(b => b.WalletBalanceId)
                .FirstOrDefaultAsync();

            pointsBalance = lastBalance?.NewPointsAmount
                ?? lastBalance?.BalancePointsAmount
                ?? 0;
        }

        return new
        {
            person.PersonId,
            person.Name,
            person.LastName,
            person.Username,
            person.Email,
            person.IsVerified,
            person.IsActive,
            PointsBalance = pointsBalance
        };
    }
}