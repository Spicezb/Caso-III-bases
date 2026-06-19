USE GathelDB;
GO

/*=========================================================
  POINTS CURRENCY
=========================================================*/

INSERT INTO currencies
(
    name,
    symbol,
    code
)
VALUES
(
    'Points',
    'PTS',
    'PTS'
);
GO

/*=========================================================
  USD -> POINTS
=========================================================*/

INSERT INTO exchangeRates
(
    currencyId,
    rate,
    isCurrent
)
SELECT
    currencyId,
    1.000000,
    1
FROM currencies
WHERE code = 'PTS';
GO

Update exchangeRates set isCurrent=0 where exchangeRateId=105

UPDATE propositions
SET minimumEntryPointsAmount =
    ABS(CHECKSUM(NEWID())) % 50 + 1;
GO

UPDATE predictions
SET pointsAmount =
    ABS(CHECKSUM(NEWID())) % 50 + 1;
GO

UPDATE predictions
SET moneyAmount =
    ABS(CHECKSUM(NEWID())) % 50 + 1;
GO

UPDATE penalties
SET pointsAmount =
    ABS(CHECKSUM(NEWID())) % 50 + 1;
GO

UPDATE predictions SET pointsAmount=NULL WHERE predictionId%3=0
UPDATE predictions SET moneyAmount=NULL WHERE predictionId%3=1

UPDATE wb
SET
    oldPointsAmount = v.oldPoints,
    balancePointsAmount = v.balancePoints,
    newPointsAmount = v.oldPoints + v.balancePoints
FROM walletBalances wb
CROSS APPLY
(
    SELECT
        ABS(CHECKSUM(NEWID())) % 31 + 70 AS oldPoints,
        ABS(CHECKSUM(NEWID())) % 41 - 20 AS balancePoints
) v;
GO

UPDATE walletTransactions SET isSelfTransaction=1 WHERE originWalletId=destinationWalletId
UPDATE walletTransactions
SET pointsAmount =
    ABS(CHECKSUM(NEWID())) % 20 + 1;
GO

UPDATE pp
SET pp.pointsPayoutAmount = wt.pointsAmount,
    pp.moneyPayoutAmount = wt.pointsAmount,
    pp.commissionAmount = wt.pointsAmount * 10/100
FROM predictionPayouts pp
INNER JOIN walletTransactions wt
    ON wt.walletTransactionId = pp.walletTransactionId;
GO

UPDATE wr
SET wr.reservedPointsAmount = p.pointsAmount,
    wr.reservedMoneyAmount = p.moneyAmount
FROM predictions p
INNER JOIN walletReservations wr
    ON wr.predictionId = p.predictionId;
GO
