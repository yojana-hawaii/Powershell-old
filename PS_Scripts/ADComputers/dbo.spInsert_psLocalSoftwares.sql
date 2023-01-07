use ADWarehouse
go

drop table if exists dbo.psLocalSoftwares;
go
create table dbo.psLocalSoftwares(
	sAMAccountName varchar(100) not null,
	[Name] varchar(100) not null,
	SoftwareName varchar(100) not null,
	SoftwareVendor  varchar(100) not null,
	SoftwareVersion  varchar(100) not null,
	SoftwareInstallation  datetime2 not null,
	ScanSuccessDate datetime2 null,
	ScanAttemptDate datetime2 null
);

go


go

drop proc if exists dbo.spInsert_psLocalSoftwares;
go

create proc dbo.spInsert_psLocalSoftwares
(
	@sAMAccountName varchar(100),
	@Name varchar(100),
	@SoftwareName varchar(100),
	@SoftwareVersion varchar(100),
	@SoftwareVendor varchar(100),
	@SoftwareInstallation varchar(100)
	
)
as 
begin
	declare @now datetime2 = getdate();
	--select @Name, @sAMAccountName, @SoftwareName, @SoftwareVendor
	update ADWarehouse.dbo.psLocalSoftwares
	set
		--SoftwareName = @SoftwareName,
		SoftwareVendor = @SoftwareVendor,
		SoftwareVersion = @SoftwareVersion,
		SoftwareInstallation = @SoftwareInstallation,
		ScanAttemptDate = @now, 
		ScanSuccessDate = @now
	where Name = @Name
		and sAMAccountName = @sAMAccountName
		and SoftwareName = @SoftwareName;
	 
	 if @@ROWCOUNT = 0
	 begin
		insert into ADWarehouse.dbo.psLocalSoftwares(
			Name, sAMAccountName, 
			SoftwareName, SoftwareVendor, SoftwareVersion,SoftwareInstallation,
			ScanAttemptDate, ScanSuccessDate
			)
		select 
			@Name, @sAMAccountName, 
			@SoftwareName, @SoftwareVendor, @SoftwareVersion,@SoftwareInstallation,
			@now, @now
	 end
	 
end 

go

select * from ADWarehouse.dbo.psLocalSoftwares
go
