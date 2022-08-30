use ADWarehouse
go
drop table if exists dbo.psADGroups;
go
create table psADGroups
(
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CanonicalName] nvarchar(100) not null,
	SamAccountName nvarchar(100) not null,
	DisplayName nvarchar(100) null,
	[Description] nvarchar(100) null,
	DistinguishedName nvarchar(100) null,
	GroupCategory nvarchar(100) null,
	GroupScope nvarchar(100) null,
	CreatedDate datetime null,
	Email nvarchar(100) null,
	UpdateDate datetime not null
)

go

drop proc if exists dbo.spInsert_psADGroups;

go

create proc dbo.spInsert_psADGroups
(
	@sAMAccountName varchar(100),
	@CanonicalName varchar(100),
	@Name  varchar(100),
	@Description  varchar(100),
	@DistinguishedName  varchar(100),
	@GroupCategory  varchar(100),
	@GroupScope  varchar(100),
	@WhenCreated  varchar(100),
	@Email varchar(100)
)
as
begin
	--select @sAMAccountName, @CanonicalName, @Name, @Description,
	--	@DistinguishedName, @GroupCategory, @GroupScope, @WhenCreated, @Email
	declare @now  datetime = getdate();

	update ADWarehouse.dbo.psADGroups
	set
		CanonicalName = CanonicalName,
		DisplayName = @Name,
		Description = @Description,
		DistinguishedName = @DistinguishedName,
		GroupCategory = @GroupCategory,
		GroupScope = @GroupScope,
		CreatedDate = convert(date,@WhenCreated),
		Email = @Email,
		UpdateDate = @now
	where 
		SamAccountName = @sAMAccountName

	if @@ROWCOUNT = 0
	begin
		insert ADWarehouse.dbo.psADGroups (
			CanonicalName, DisplayName, Description, DistinguishedName, GroupCategory,
			GroupScope, CreatedDate, Email, SamAccountName, UpdateDate
			)
		select @CanonicalName, @Name, @Description,
			@DistinguishedName, @GroupCategory, 
			@GroupScope, @WhenCreated, @Email, @sAMAccountName, @now
	end
end

go

select * from ADWarehouse.dbo.psADGroups

go