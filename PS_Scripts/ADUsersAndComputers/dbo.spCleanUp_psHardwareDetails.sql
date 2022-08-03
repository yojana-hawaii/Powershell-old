use ADWarehouse
go

drop proc if exists dbo.spCleanUp_psHardwareDetails;
go
create proc dbo.spCleanUp_psHardwareDetails
as
begin


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

end

exec ADWarehouse.dbo.spCleanUp_psHardwareDetails
go