
use ADWarehouse
go

drop table if exists [dbo].[psADUSers];
go
CREATE TABLE [dbo].[psADUSers](
	[ID] [int] IDENTITY(1,1) NOT NULL,

	[UserName] nvarchar(100) NOT NULL unique,
	Enabled bit not null,
	EmployeeID nvarchar(100) not null,
	[CanonicalName] nvarchar(100) not null,
	[FirstName] nvarchar(100) NULL,
	[LastName] nvarchar(100) NULL,
	[DisplayName] nvarchar(100) NULL,
	[Address] nvarchar(100) NULL,
	[Email] nvarchar(100) NULL,
	[LogonScript] nvarchar(100) NULL,
	[Department] nvarchar(100) NULL,
	[Title] nvarchar(100) NULL,
	[Company] nvarchar(100) NULL,
	[Extension] nvarchar(100) NULL,
	[FullNumber] nvarchar(100) NULL,
	[SecondaryNumber] nvarchar(100) NULL,
	[Fax] nvarchar(100) NULL,
	[LogonCount] nvarchar(100) NULL,
	[DistinguishedName] nvarchar(100) NULL,
	[Description] nvarchar(100) NULL,
	[Manager] nvarchar(100) NULL,

	[WhenCreated] datetime NULL,
	[LastLogonDate] date NULL,
	AccountExpires date null,
	PasswordLastSet date not null,

	PasswordNeverExpires bit not null,
	PasswordExpired bit not null,

	ScanSuccessDate datetime not null

 CONSTRAINT [PK_dimADUsers] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

drop proc if exists dbo.spInsert_psADUsers;
go
create proc dbo.spInsert_psADUsers
(
	@sAMAccountName varchar(100),
	@CanonicalName varchar(100),
	@FirstName  varchar(100),
	@LastName  varchar(100),
	@DisplayName  varchar(100),
	
	@Email  varchar(100),
	@DistinguishedName  varchar(100),
	@Address  varchar(100),
	@FullNumber varchar(100),
	@SecondaryNumber  varchar(100),
	@Extension varchar(100),
	@Fax varchar(100),

	@Company varchar(100),
	@Title varchar(100),
	@Description varchar(100),
	@AccountExpires varchar(100),
	@Enabled varchar(100),
	@LastLogonDate varchar(100),
	@Department varchar(100),

	@WhenCreated varchar(100),
	@PasswordNeverExpires varchar(100),
	@PasswordExpired varchar(100),
	@PasswordLastSet varchar(100),
	@LogonScript varchar(100),
	@LogonCount varchar(100),
	@EmployeeId varchar(100),
	@Manager varchar(100)

)
as
begin

--select 
--			@sAMAccountName, @CanonicalName, @FirstName, @LastName, @DisplayName,
--			@Email, @DistinguishedName, @Address, @FullNumber, @SecondaryNumber, @Extension, @Fax,
--			@Company, @Title, @Description,convert(date,@AccountExpires) acctExp, @Enabled,convert(date,@LastLogonDate) lastLogon, @Department,
--			convert(date,@WhenCreated) Created, @PasswordNeverExpires, @PasswordExpired, convert(date,@PasswordLastSet) pwdSet, @LogonScript, @LogonCount, @EmployeeId, @Manager

	declare @now datetime = getdate();
	update ADWarehouse.dbo.psADUSers
	set 
		CanonicalName = @CanonicalName,
		FirstName = @FirstName,
		LastName = @LastName,
		DisplayName = @DisplayName,
		Email = @Email,
		DistinguishedName = @DistinguishedName,
		Address = @Address,
		FullNumber = @FullNumber,
		SecondaryNumber = @SecondaryNumber,
		Extension = @Extension,
		Fax = @Fax,
		Company = @Company,
		Department = @Department,
		Title = @Title,
		Description = @Description,
		Enabled = @Enabled,
		AccountExpires = convert(date,@AccountExpires),
		LastLogonDate = convert(date,@LastLogonDate),
		WhenCreated = convert(datetime, @WhenCreated),
		PasswordLastSet = convert(date,@PasswordLastSet), 
		PasswordNeverExpires = @PasswordNeverExpires, 
		[PasswordExpired] = @PasswordExpired, 
		LogonScript = @LogonScript, 
		LogonCount = @LogonCount, 
		EmployeeID = @EmployeeId, 
		Manager = @Manager,
		ScanSuccessDate = @now
	where 
		UserName = @sAMAccountName

	if @@ROWCOUNT = 0
	begin
		insert ADWarehouse.dbo.psADUSers(
			UserName, CanonicalName,FirstName,LastName,DisplayName,
			Email,DistinguishedName,Address,FullNumber,SecondaryNumber,Extension,Fax,
			Company,Title,Description,
			LogonScript, LogonCount, EmployeeID, Manager,Department,
			Enabled,
			PasswordNeverExpires, 
			[PasswordExpired], 
			AccountExpires,
			LastLogonDate,
			WhenCreated,
			PasswordLastSet,
			ScanSuccessDate
		)
		select 
			@sAMAccountName, @CanonicalName, @FirstName, @LastName, @DisplayName,
			@Email, @DistinguishedName, @Address, @FullNumber, @SecondaryNumber, @Extension, @Fax,
			@Company, @Title, @Description,
			@LogonScript, @LogonCount, @EmployeeId, @Manager, @Department,
			@Enabled,
			@PasswordNeverExpires, 
			@PasswordExpired, 
			convert(date,@AccountExpires), 
			convert(date,@LastLogonDate), 
			convert(datetime, @WhenCreated), 
			convert(date,@PasswordLastSet),
			@now
	end
end
go

select * from ADWarehouse.dbo.psADUSers
go