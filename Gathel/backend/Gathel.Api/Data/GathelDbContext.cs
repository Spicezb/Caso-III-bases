using Gathel.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Gathel.Api.Data;

public class GathelDbContext : DbContext
{
    public GathelDbContext(DbContextOptions<GathelDbContext> options)
        : base(options)
    {
    }

    public DbSet<Person> People => Set<Person>();
    public DbSet<Proposition> Propositions => Set<Proposition>();
    public DbSet<Prediction> Predictions => Set<Prediction>();
    public DbSet<StatusType> StatusTypes => Set<StatusType>();
    public DbSet<Wallet> Wallets => Set<Wallet>();
    public DbSet<WalletBalance> WalletBalances => Set<WalletBalance>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<NotificationType> NotificationTypes => Set<NotificationType>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Person>(entity =>
        {
            entity.ToTable("people");
            entity.HasKey(e => e.PersonId);

            entity.Property(e => e.PersonId).HasColumnName("personId");
            entity.Property(e => e.PeopleTypeId).HasColumnName("peopleTypeId");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.LastName).HasColumnName("lastName");
            entity.Property(e => e.Identification).HasColumnName("identification");
            entity.Property(e => e.Phone).HasColumnName("phone");
            entity.Property(e => e.Email).HasColumnName("email");
            entity.Property(e => e.Username).HasColumnName("username");
            entity.Property(e => e.Biography).HasColumnName("biography");
            entity.Property(e => e.IsVerified).HasColumnName("isVerified");
            entity.Property(e => e.IsActive).HasColumnName("isActive");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");
            entity.Property(e => e.CreatedAt).HasColumnName("createdAt");
            entity.Property(e => e.UpdatedAt).HasColumnName("updatedAt");
        });

        modelBuilder.Entity<Proposition>(entity =>
        {
            entity.ToTable("propositions");
            entity.HasKey(e => e.PropositionId);

            entity.Property(e => e.PropositionId).HasColumnName("propositionId");
            entity.Property(e => e.ParentProposition).HasColumnName("parentproposition");
            entity.Property(e => e.StatusTypesId).HasColumnName("statusTypesId");
            entity.Property(e => e.CreatorPersonId).HasColumnName("creatorPersonId");
            entity.Property(e => e.TargetPersonId).HasColumnName("targetPersonId");
            entity.Property(e => e.TargetSocialAccountId).HasColumnName("targetSocialAccountId");
            entity.Property(e => e.Title).HasColumnName("title");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.StartPredictionDateTime).HasColumnName("startPredictionDateTime");
            entity.Property(e => e.EndPredictionDateTime).HasColumnName("endPredictionDateTime");
            entity.Property(e => e.WinningOption).HasColumnName("winningOption");
            entity.Property(e => e.MinimumEntryPointsAmount).HasColumnName("minimumEntryPointsAmount");
            entity.Property(e => e.WinningProfitPercentage).HasColumnName("winningProfitPercentage");
            entity.Property(e => e.IsPublic).HasColumnName("isPublic");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");
            entity.Property(e => e.CreatedAt).HasColumnName("createdAt");
            entity.Property(e => e.UpdatedAt).HasColumnName("updatedAt");
        });

        modelBuilder.Entity<Prediction>(entity =>
        {
            entity.ToTable("predictions");
            entity.HasKey(e => e.PredictionId);

            entity.Property(e => e.PredictionId).HasColumnName("predictionId");
            entity.Property(e => e.StatusTypesId).HasColumnName("statusTypesId");
            entity.Property(e => e.PropositionId).HasColumnName("propositionId");
            entity.Property(e => e.PersonId).HasColumnName("personId");
            entity.Property(e => e.PredictionValue).HasColumnName("predictionValue");
            entity.Property(e => e.PointsAmount).HasColumnName("pointsAmount");
            entity.Property(e => e.MoneyAmount).HasColumnName("moneyAmount");
            entity.Property(e => e.CurrencyId).HasColumnName("currencyId");
            entity.Property(e => e.ExchangeRateId).HasColumnName("exchangeRateId");
            entity.Property(e => e.PredictionDateTime).HasColumnName("predictionDateTime");
            entity.Property(e => e.IsWinner).HasColumnName("isWinner");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");
            entity.Property(e => e.CreatedAt).HasColumnName("createdAt");
            entity.Property(e => e.UpdatedAt).HasColumnName("updatedAt");
        });

        modelBuilder.Entity<StatusType>(entity =>
        {
            entity.ToTable("statusTypes");
            entity.HasKey(e => e.StatusTypeId);

            entity.Property(e => e.StatusTypeId).HasColumnName("statusTypeId");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");
        });

        modelBuilder.Entity<Wallet>(entity =>
        {
            entity.ToTable("wallets");
            entity.HasKey(e => e.WalletId);

            entity.Property(e => e.WalletId).HasColumnName("walletId");
            entity.Property(e => e.PersonId).HasColumnName("personId");
            entity.Property(e => e.IsBlocked).HasColumnName("isBlocked");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");
        });

        modelBuilder.Entity<WalletBalance>(entity =>
        {
            entity.ToTable("walletBalances");
            entity.HasKey(e => e.WalletBalanceId);

            entity.Property(e => e.WalletBalanceId).HasColumnName("walletBalanceId");
            entity.Property(e => e.WalletId).HasColumnName("walletId");
            entity.Property(e => e.StatusTypeId).HasColumnName("statusTypeId");
            entity.Property(e => e.OldPointsAmount).HasColumnName("oldPointsAmount");
            entity.Property(e => e.BalancePointsAmount).HasColumnName("balancePointsAmount");
            entity.Property(e => e.NewPointsAmount).HasColumnName("newPointsAmount");
            entity.Property(e => e.CalculatedAt).HasColumnName("calculatedAt");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.ToTable("notifications");
            entity.HasKey(e => e.NotificationId);

            entity.Property(e => e.NotificationId).HasColumnName("notificationId");
            entity.Property(e => e.NotificationTypeId).HasColumnName("notificationTypeId");
            entity.Property(e => e.PersonId).HasColumnName("personId");
            entity.Property(e => e.Title).HasColumnName("title");
            entity.Property(e => e.Message).HasColumnName("message");
            entity.Property(e => e.IsRead).HasColumnName("isRead");
            entity.Property(e => e.ReadAt).HasColumnName("readAt");
            entity.Property(e => e.ReferenceTypeId).HasColumnName("referenceTypeId");
            entity.Property(e => e.ReferenceId).HasColumnName("referenceId");
            entity.Property(e => e.AuditPersonId).HasColumnName("auditPersonId");
            entity.Property(e => e.CreatedAt).HasColumnName("createdAt");
            entity.Property(e => e.UpdatedAt).HasColumnName("updatedAt");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");
        });

        modelBuilder.Entity<NotificationType>(entity =>
        {
            entity.ToTable("notificationTypes");
            entity.HasKey(e => e.NotificationTypeId);

            entity.Property(e => e.NotificationTypeId).HasColumnName("notificationTypeId");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.AuditPersonId).HasColumnName("auditPersonId");
            entity.Property(e => e.CreatedAt).HasColumnName("createdAt");
            entity.Property(e => e.UpdatedAt).HasColumnName("updatedAt");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");
        });
    }
}