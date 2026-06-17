namespace Gathel.Api.Models;

public class WalletBalance
{
    public int WalletBalanceId { get; set; }
    public int? WalletId { get; set; }
    public int? StatusTypeId { get; set; }

    public decimal? OldPointsAmount { get; set; }
    public decimal? BalancePointsAmount { get; set; }
    public decimal? NewPointsAmount { get; set; }

    public DateTime CalculatedAt { get; set; }
    public bool IsDeleted { get; set; }
}