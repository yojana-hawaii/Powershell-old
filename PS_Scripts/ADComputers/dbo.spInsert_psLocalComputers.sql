use [ADWarehouse]
go

drop table if exists dbo.psLocalComputers;
go

create table dbo.psLocalComputers (
	sAMAccountName varchar(100) not null,
	[Name] varchar(100) not null,
	SerialNumber varchar(50) null,
	Last_Security_KB varchar(50) null,
	Last_SecurityPatch_date datetime2 null,
	LastPatchKb varchar(50) null,
	LastPatchDate datetime2 null,
	Print_Status varchar(50) null,
	Kace_status varchar(50) null,
	Sentinel_Status varchar(50) null,
	Sysaid_Status varchar(50) null,
	DellEncryption_Status varchar(50) null,
	Cylance_Status varchar(50) null,
	Print_LocalSpl_date datetime2 null,
	Print_SpoolSv_date datetime2 null,
	Print_Win32Spl_date datetime2 null,
	Manufacturer varchar(50) null,
	Model varchar(50) null,
	RAM_GB float null,
	VM tinyint null,
	Processor varchar(50) null,
	BiosVersion varchar(50) null,
	[Offline] tinyint null,
	IsLaptop tinyint null,
	
	LastReboot datetime2 null,
	Currentuser varchar(50) null,
	WakeUpType  varchar(50) null,
	EncryptionLevel  varchar(50) null,
	NumberOfUsers  varchar(50) null,
	OSArchitechture  varchar(50) null,
	DiskModel  varchar(50) null,
	DiskSizeGB  varchar(50) null,
	DiskType  varchar(50) null,

	TpmEnabled varchar(50) null,
	TpmVersion varchar(50) null,
	BiosReleaseDate varchar(50) null,
	ScanSuccessDate datetime2 null,
	ScanAttemptDate datetime2 null

);

go



drop proc if exists dbo.spInsert_psLocalComputers;
go
create proc dbo.spInsert_psLocalComputers
(
	@sAMAccountName varchar(100),
	@Name varchar(100),
	@SerialNumber varchar(50) ,
	@Last_Security_KB varchar(50) ,
	@Last_SecurityPatch_date varchar(50) ,
	@Print_Status varchar(50) ,
	@Kace_status varchar(50) ,
	@Sentinel_Status varchar(50) ,
	@Sysaid_Status varchar(50) ,
	@DellEncryption_Status varchar(50) ,
	@Cylance_Status varchar(50) ,
	@Print_LocalSpl_date varchar(50) ,
	@Print_SpoolSv_date varchar(50) ,
	@Print_Win32Spl_date varchar(50) ,
	@Manufacturer varchar(50) ,
	@Model varchar(50) ,
	@RAM_GB varchar(50) ,
	@VM varchar(50) ,
	@Processor varchar(50) ,
	@BiosVersion varchar(50) ,
	@Offline varchar(50) ,
	@IsLaptop varchar(50) ,

	@LastReboot varchar(50) ,
	@CurrentUser varchar(50) ,
	@WakeUpType varchar(50) ,
	@EncryptionLevel varchar(50) ,
	@NumberOfUsers varchar(50) ,
	@OSArchitecture varchar(50) ,
	@DiskModel varchar(50) ,
	@DiskSizeGB varchar(50) ,
	@DiskType varchar(50),
	@TpmVersion varchar(50),
	@TpmEnabled varchar(50),
	@BiosReleaseDate varchar(50),
	@LastPatchKb varchar(50) ,
	@LastPatchDate varchar(50) 
)
as
begin
	declare @now datetime2 = getdate();
	--select @Name, @Offline, @sAMAccountName

	--update table if computer online  & name and sAMAccountName matches -> get latest information
	update ADWarehouse.dbo.psLocalComputers
	set
		--Name = @Name,
		SerialNumber = @SerialNumber,
		Last_Security_KB = @Last_Security_KB,
		Last_SecurityPatch_date = convert(date, @Last_SecurityPatch_date),
		Print_Status = @Print_Status,
		Kace_status = @Kace_status,
		Sentinel_Status = @Sentinel_Status,
		Sysaid_Status = @Sysaid_Status,
		DellEncryption_Status = @DellEncryption_Status,
		Cylance_Status = @Cylance_Status,
		Print_LocalSpl_date = convert(date, @Print_LocalSpl_date),
		Print_SpoolSv_date = convert(date, @Print_SpoolSv_date),
		Print_Win32Spl_date = convert(date, @Print_Win32Spl_date),
		Manufacturer = @Manufacturer,
		Model = @Model,
		RAM_GB = @RAM_GB,
		VM = @VM,
		Processor = @Processor,
		BiosVersion = @BiosVersion,
		Offline = @Offline,
		IsLaptop = @IsLaptop,

		LastReboot = @LastReboot,
		Currentuser = @CurrentUser,
		WakeUpType = @WakeUpType,
		EncryptionLevel = @EncryptionLevel,
		NumberOfUsers = @NumberOfUsers,
		OSArchitechture = @OSArchitecture,
		DiskModel = @DiskModel,
		DiskSizeGB = @DiskSizeGB,
		DiskType = @DiskType,

		TpmEnabled = @TpmEnabled,
		TpmVersion = @TpmVersion,
		BiosReleaseDate = @BiosReleaseDate,

		LastPatchKb = @LastPatchKb,
		LastPatchDate = @LastPatchDate,
		ScanSuccessDate = @now,
		ScanAttemptDate = @now
	where Name = @Name
		and @Offline = 0
		and sAMAccountName = @sAMAccountName;

	
	--if online & no match with name and sAMAccountName -> add new entry
	 if @@ROWCOUNT = 0
	 begin
		insert into ADWarehouse.dbo.psLocalComputers(
			sAMAccountName,Name,SerialNumber,Last_Security_KB,Last_SecurityPatch_date,Print_Status,Kace_status,Sentinel_Status,
			Sysaid_Status,DellEncryption_Status,Cylance_Status,Print_LocalSpl_date,Print_SpoolSv_date,Print_Win32Spl_date,
			Manufacturer,Model,RAM_GB,vm,Processor,BiosReleaseDate,BiosVersion,Offline,IsLaptop,LastReboot,Currentuser,WakeUpType,
			EncryptionLevel,NumberOfUsers,OSArchitechture,DiskModel,DiskSizeGB,DiskType,ScanSuccessDate,ScanAttemptDate,
			TpmEnabled,TpmVersion,LastPatchKb,LastPatchDate
		)
		select 
			@sAMAccountName,@Name,@SerialNumber,@Last_Security_KB,@Last_SecurityPatch_date,@Print_Status,@Kace_status,@Sentinel_Status,
			@Sysaid_Status,@DellEncryption_Status,@Cylance_Status,@Print_LocalSpl_date,@Print_SpoolSv_date,@Print_Win32Spl_date,
			@Manufacturer,@Model,@RAM_GB,@VM,@Processor,@BiosReleaseDate,@BiosVersion,@Offline,@IsLaptop,@LastReboot,@Currentuser,@WakeUpType,
			@EncryptionLevel,@NumberOfUsers,@OSArchitecture,@DiskModel,@DiskSizeGB,@DiskType,@now,@now,
			@TpmEnabled,@TpmVersion,@LastPatchKb,@LastPatchDate
		where @Offline = 0
	 end
	
	--if offline & matches name and sAMAccountName -> update to offline
	if @@ROWCOUNT = 0
	begin
		update ADWarehouse.dbo.psLocalComputers
		set
			Offline = @Offline,
			ScanAttemptDate = @now
		where Name = @Name
			and @Offline = 1
			and sAMAccountName = @sAMAccountName;
	end

	--if offline & no match with name and sAMAccountName -> add new entry saying offline 
	if @@ROWCOUNT = 0
	 begin
		insert into ADWarehouse.dbo.psLocalComputers(
			sAMAccountName,Name,SerialNumber,Last_Security_KB,Last_SecurityPatch_date,Print_Status,Kace_status,Sentinel_Status,
			Sysaid_Status,DellEncryption_Status,Cylance_Status,Print_LocalSpl_date,Print_SpoolSv_date,Print_Win32Spl_date,
			Manufacturer,Model,RAM_GB,vm,Processor,BiosReleaseDate,BiosVersion,Offline,IsLaptop,LastReboot,Currentuser,WakeUpType,
			EncryptionLevel,NumberOfUsers,OSArchitechture,DiskModel,DiskSizeGB,DiskType,ScanSuccessDate,ScanAttemptDate,
			TpmEnabled,TpmVersion,LastPatchKb,LastPatchDate
		)
		select 
			@sAMAccountName,@Name,@SerialNumber,@Last_Security_KB,@Last_SecurityPatch_date,@Print_Status,@Kace_status,@Sentinel_Status,
			@Sysaid_Status,@DellEncryption_Status,@Cylance_Status,@Print_LocalSpl_date,@Print_SpoolSv_date,@Print_Win32Spl_date,
			@Manufacturer,@Model,@RAM_GB,@VM,@Processor,@BiosReleaseDate,@BiosVersion,@Offline,@IsLaptop,@LastReboot,@Currentuser,@WakeUpType,
			@EncryptionLevel,@NumberOfUsers,@OSArchitecture,@DiskModel,@DiskSizeGB,@DiskType,null,@now,
			@TpmEnabled,@TpmVersion,@LastPatchKb,@LastPatchDate
		where @Offline = 1

	 end

	select @Name name,@sAMAccountName sam,@Offline offline
end
go
--exec dbo.spInsert_psLocalComputers 'x','y','123',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null

select * from ADWarehouse.dbo.psLocalComputers
where name in ('x','y')
order by ScanAttemptDate desc

go