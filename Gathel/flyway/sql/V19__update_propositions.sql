USE GathelDB;
GO

update propositions set statusTypesId=9 where (statusTypesId=11 and propositionId%3=0)
update propositions set statusTypesId=11 where (statusTypesId=9 and propositionId%5=0)
update propositions set winningOption=NULL where statusTypesId=9
update propositions set winningOption=1 where (winningOption IS NULL and statusTypesId=11 and propositionId%2=1)
update propositions set winningOption=0 where (winningOption IS NULL and statusTypesId=11 and propositionId%2=0)
update propositions set statusTypesId=2 where (statusTypesId=9 and propositionId%7=0)
update propositions set statusTypesId=10 where (statusTypesId=9 and propositionId%8=0)