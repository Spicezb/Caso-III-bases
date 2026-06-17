namespace Gathel.Api.Models;

public class Wallet
{
    public int WalletId { get; set; }
    public int? PersonId { get; set; }

    public bool IsBlocked { get; set; }
    public bool IsDeleted { get; set; }
}