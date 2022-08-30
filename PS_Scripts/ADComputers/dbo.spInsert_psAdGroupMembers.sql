use ADWarehouse
go
drop table if exists dbo.psAdGroupMembers;
go
create table dbo.psAdGroupMembers(
	[ID] [int] IDENTITY(1,1) NOT NULL,
	GroupSamAccountName nvarchar(100) not null,
	Username nvarchar(100) null,
	ObjectClass nvarchar(100) null,
	UpdateDate datetime not null,
	)
go
drop proc if exists dbo.spInsert_psAdGroupMembers;

go
create proc dbo.spInsert_psAdGroupMembers
(
	@GroupSamAccountName nvarchar(100),
	@UserName nvarchar(100),
	@ObjectClass nvarchar(100)
)
as
begin
	--select @GroupSamAccountName, @UserName, @ObjectClass
	declare @now datetime =  getdate();

	update ADWarehouse.dbo.psAdGroupMembers
	set UpdateDate = @now
	where
		GroupSamAccountName = @GroupSamAccountName
		and Username = @UserName
		and ObjectClass = @ObjectClass

	if @@ROWCOUNT = 0
	begin
		insert into ADWarehouse.dbo.psAdGroupMembers (
			GroupSamAccountName, Username, ObjectClass,
			UpdateDate
			)
		select @GroupSamAccountName, @UserName, @ObjectClass,
			@now
	end

end

go

select * from dbo.psAdGroupMembers
go