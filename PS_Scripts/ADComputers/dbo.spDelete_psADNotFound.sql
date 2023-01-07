use ADWarehouse
go

drop proc if exists dbo.spDelete_psADNotFound;
go
create proc dbo.spDelete_psADNotFound
(
	@sAMAccountName varchar(50)	
)
as
begin

	

	delete--select * 
	from dbo.psADComputers 
	where sAMAccountName = @sAMAccountName;
	
	delete--select * 
	from dbo.psLocalComputers 
	where sAMAccountName = @sAMAccountName;

	delete--select * 
	from dbo.psLocalMonitor
	where sAMAccountName = @sAMAccountName;

	delete--select * 
	from dbo.psLocalPrinters
	where sAMAccountName = @sAMAccountName;

	delete--select * 
	from dbo.psLocalUsers
	where sAMAccountName = @sAMAccountName;


end

go

exec dbo.spDelete_psADNotFound 'ayush-vm$'
go