

use ADWarehouse
go

drop proc if exists dbo.spCleanUp_psTables;
go

create proc dbo.spCleanUp_psTables
as
begin

	update ADWarehouse.dbo.psADComputers
	set BitLockerPasswordDate = null,
		BitLockerEnabled = 0
	where BitLockerPasswordDate = '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psADComputers
	set BitLockerEnabled = 1
	where BitLockerPasswordDate != '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psADComputers
	set LastLogonDate = null
	where LastLogonDate = '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psADComputers
	set IPV4Address= null
	where IPV4Address = '';

	update ADWarehouse.dbo.psADComputers
	set Description= null
	where Description = '';


	update ADWarehouse.dbo.psADComputers
	set Location = 'Building 1 Floor 1'
	where IPV4Address like 'x.x.x.%' or IPV4Address like 'x.x.x.%'


	update ADWarehouse.dbo.psADComputers
	set Location = 'Remote Users' ,
		VPN = 1
	where IPV4Address like 'x.x.%' 
	
	update ADWarehouse.dbo.psADComputers
	set vpn = 0
	where vpn is null

	update ADWarehouse.dbo.psADComputers
	set LocalDetails = 1
	where Active = 1 
		and IPV4Address is not null
		and OperatingSystem like '%Windows%' 
		and OU not like '%no domain%'
		and Name not like '%cluster%'
		and Name not like '%replication%'


	update ADWarehouse.dbo.psADComputers
	set LocalDetails = 0
	where LocalDetails is null


	update ADWarehouse.dbo.psLocalComputers
	set Last_SecurityPatch_date = null
	where Last_SecurityPatch_date = '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psLocalComputers
	set LastPatchDate = null
	where LastPatchDate = '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psLocalComputers
	set LastPatchKb = null
	where LastPatchKb = '';

	update ADWarehouse.dbo.psLocalComputers
	set Print_LocalSpl_date = null
	where Print_LocalSpl_date = '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psLocalComputers
	set Print_SpoolSv_date = null
	where Print_SpoolSv_date = '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psLocalComputers
	set Print_Win32Spl_date = null
	where Print_Win32Spl_date = '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psLocalComputers
	set LastReboot = null
	where LastReboot = '1900-01-01 00:00:00.0000000';

	update ADWarehouse.dbo.psLocalComputers
	set VM = 0
	where VM is null;

	update ADWarehouse.dbo.psLocalUsers
	set UserLastLoginDate = null
	where UserLastLoginDate = '1900-01-01 00:00:00.0000000'
)
	
end
go
exec ADWarehouse.dbo.spCleanUp_psTables;
go