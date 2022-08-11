use ADWarehouse
go

--drop table if exists dbo.psLocalMonitor;
go
create table dbo.psLocalMonitor(
	sAMAccountName varchar(100) not null,
	[Name] varchar(100) not null,
	MonitorManufacturer  varchar(100) null,
	MonitorName  varchar(50) null,
	MonitorSerial  varchar(50) null,
	MonitorYear varchar(50) null,
	MonitorCaption varchar(50) null,
	MonitorResolution varchar(50) null,
);
go
drop proc if exists dbo.spInsert_psLocalMonitor;
go
create proc dbo.spInsert_psLocalMonitor
(
	@sAMAccountName varchar(100),
	@Name varchar(100),
	@MonitorManufacturer  varchar(100),
	@MonitorName  varchar(50) ,
	@MonitorSerial  varchar(50) ,
	@MonitorYear varchar(50) ,
	@MonitorCaption varchar(50),
	@MonitorResolution varchar(50)
)
as 
begin
	declare @now datetime2 = getdate();
	--select @sAMAccountName, @Name

	update ADWarehouse.dbo.psLocalMonitor
	set MonitorName = @MonitorName,
		MonitorManufacturer = @MonitorManufacturer,
		MonitorYear = @MonitorYear,
		MonitorCaption = @MonitorCaption,
		MonitorResolution = @MonitorResolution
	where name = @Name
		and sAMAccountName = @sAMAccountName
		and MonitorSerial = @MonitorSerial

	if @@ROWCOUNT = 0
	begin
		insert into ADWarehouse.dbo.psLocalMonitor(
			sAMAccountName,Name,
			MonitorName, MonitorManufacturer,MonitorYear, 
			MonitorCaption, MonitorResolution,MonitorSerial
		)
		select @sAMAccountName,@Name,
			@MonitorName, @MonitorManufacturer,@MonitorYear, 
			@MonitorCaption, @MonitorResolution,@MonitorSerial
	end
end

go

select * from psLocalMonitor
go
