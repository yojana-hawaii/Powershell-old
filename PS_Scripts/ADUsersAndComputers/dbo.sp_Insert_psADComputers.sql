USE [ADWarehouse]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--drop table if exists dbo.psADComputers;
go
create table dbo.psADComputers (
	sAMAccountName varchar(100) not null,
	[Name] varchar(100) not null,
	DistinguishedName varchar(500) not null,
	Created datetime2 not null,
	Modified datetime2 not null,
	UserAccountControl int not null,
	[IPV4Address] varchar(30) null,
	LastLogonDate datetime2 null,
	LogonCount int null,
	[Description] nvarchar(max) null,
	OU varchar(100) not null,
	[Active] tinyint not null,
	[Server] tinyint not null,
	[Thin_Client] tinyint not null,
	BitLockerPasswordDate datetime2 null,
	OperatingSystem varchar(100)  null,
	OperatingSystemVersion varchar(100)  null,
	OSVersion varchar(50) null,
	[Location] varchar(50) null,
	LastUpdated datetime2 not null,
	BitLockerEnabled tinyint not null,

);

go
drop proc if exists dbo.spInsert_psADComputers;

go

create proc dbo.spInsert_psADComputers
(
	@Name varchar(100), 
	@DistinguishedName varchar(500),
	@Created varchar(100) ,
	@Modified varchar(100),
	@UserAccountControl varchar(100) ,
	@IPV4Address varchar(30),
	@LastLogonDate varchar(100) ,
	@LogonCount varchar(100) ,
	@Description nvarchar(500) ,
	@OU varchar(100) ,
	@Active varchar(100) ,
	@Server varchar(100) ,
	@Thin_Client varchar(100) ,
	@BitLockerPasswordDate varchar(100) ,
	@OperatingSystem varchar(100)  ,
	@OperatingSystemVersion varchar(100)  ,
	@OSVersion varchar(50),
	@sAMAccountName varchar(100)
)
as begin
	update ADWarehouse.dbo.psADComputers
	set
		[Name] = @Name,
		DistinguishedName = @DistinguishedName,
		Created = @Created,
		Modified = @Modified,
		UserAccountControl = @UserAccountControl, 
		IPV4Address = @IPV4Address,
		LastLogonDate = @LastLogonDate,
		LogonCount = @LogonCount,
		[Description] = @Description,
		ou = @OU,
		Active = @Active,
		[Server] = @Server,
		Thin_Client = @Thin_Client,
		BitLockerPasswordDate = @BitLockerPasswordDate,
		OperatingSystem = @OperatingSystem,
		OperatingSystemVersion = @OperatingSystemVersion,
		OSVersion = @OSVersion,
		LastUpdated = getdate()

	where 
		sAMAccountName = @sAMAccountName

	if @@RowCount = 0
	begin
		insert into ADWarehouse.dbo.psADComputers(
			[Name], DistinguishedName, Created, Modified, UserAccountControl, 
            IPV4Address, LastLogonDate,LogonCount,[Description],
			OU,Active,[Server],Thin_Client,BitLockerPasswordDate,
            OperatingSystem,OperatingSystemVersion, OSVersion,sAMAccountName,
			LastUpdated
		)
	select 
		@Name, @DistinguishedName, @Created, @Modified, @UserAccountControl,
		@IPV4Address, @LastLogonDate, @LogonCount,@Description, 
        @ou, @Active, @Server, @Thin_Client, @BitLockerPasswordDate,
		@OperatingSystem, @OperatingSystemVersion, @OSVersion, @sAMAccountName, 
		getdate()
	end
 

end

go 

go


select * from ADWarehouse.dbo.psADComputers order by LastLogonDate desc

go
