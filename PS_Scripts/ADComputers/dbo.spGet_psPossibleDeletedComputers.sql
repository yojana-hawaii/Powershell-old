use ADWarehouse
go

drop proc if exists dbo.spGet_psPossibleDeletedComputers;

go

create proc dbo.spGet_psPossibleDeletedComputers
as
begin
	select sAMAccountName,Name 
	from dbo.psADComputers
	where datediff(day,convert(date,ScanSuccessDate) , convert(date, getdate() ) ) > 30

end
go
exec dbo.spGet_psPossibleDeletedComputers
go