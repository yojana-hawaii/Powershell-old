use ADWarehouse
go

--drop table if exists dbo.psLocalUsers;
go
create table dbo.psLocalUsers(
	sAMAccountName varchar(100) not null,
	[Name] varchar(100) not null,
	UsersLoggedIn  varchar(100) null,
	UserLastLoginDate  datetime2 null,
	ScanSuccessDate datetime2 null,
);
go

drop proc if exists dbo.spInsert_psLocalUsers;
go

create proc dbo.spInsert_psLocalUsers
(
	@sAMAccountName varchar(100),
	@Name varchar(100),
	@UsersLoggedIn  varchar(100),
	@UserLastLoginDate  varchar(50)
)
as 
begin
	declare @now datetime2 = getdate();
	--select @sAMAccountName, @Name

	update ADWarehouse.dbo.psLocalUsers
	set UserLastLoginDate = @UserLastLoginDate,
		ScanSuccessDate = @now
	where name = @Name
		and sAMAccountName = @sAMAccountName
		and UsersLoggedIn = @UsersLoggedIn
		and @UsersLoggedIn not in ('NT AUTHORITY\SYSTEM','NT AUTHORITY\LOCAL SERVICE','NT AUTHORITY\NETWORK SERVICE')

	if @@ROWCOUNT = 0
	begin
		insert into ADWarehouse.dbo.psLocalUsers(
			sAMAccountName,Name,
			UserLastLoginDate, UsersLoggedIn,
			ScanSuccessDate
		)
		select @sAMAccountName,@Name,
			@UserLastLoginDate, @UsersLoggedIn,
			@now
		where @UsersLoggedIn not in ('NT AUTHORITY\SYSTEM','NT AUTHORITY\LOCAL SERVICE','NT AUTHORITY\NETWORK SERVICE')
	end

end

go

select * from ADWarehouse.dbo.psLocalUsers
go