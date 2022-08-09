use ADWarehouse
go

drop table if exists dbo.psLocalPrinters;
go
create table dbo.psLocalPrinters(
	sAMAccountName varchar(100) not null,
	[Name] varchar(100) not null,
	PrinterName  varchar(100) null,
	PrinterShared  varchar(50) null,
	PrinterDriverName  varchar(50) null,
	PrinterIP varchar(50) null,
	PrinterDriverVersion varchar(50) null,
);
go

drop proc if exists dbo.spInsert_psLocalPrinters;
go
create proc dbo.spInsert_psLocalPrinters
(
	@sAMAccountName varchar(100),
	@Name varchar(100),
	@PrinterName  varchar(100),
	@PrinterShared  varchar(50) ,
	@PrinterDriverName  varchar(50) ,
	@PrinterIP varchar(50) ,
	@PrinterDriverVersion varchar(50)
)
as
begin
	declare @now datetime2 = getdate();
	select @sAMAccountName, @Name

	update ADWarehouse.dbo.psLocalPrinters
	set PrinterName = @PrinterName,
		PrinterDriverName  =@PrinterDriverName,
		PrinterDriverVersion = @PrinterDriverVersion,
		PrinterShared = @PrinterShared
	where name = @Name
		and sAMAccountName = @sAMAccountName
		and PrinterIP = @PrinterIP

	if @@ROWCOUNT = 0
	begin
		insert into ADWarehouse.dbo.psLocalPrinters(
			sAMAccountName,Name,
			PrinterDriverName, PrinterDriverVersion, 
			PrinterIP, PrinterName
		)
		select @sAMAccountName,@Name,
			@PrinterDriverName, @PrinterDriverVersion, 
			@PrinterIP, @PrinterName
	end
end

go
select * from dbo.psLocalPrinters
go