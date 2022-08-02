

use ADWarehouse
go

drop proc if exists dbo.spCleanUp_psADComputer;
go

create proc dbo.spCleanUp_psADComputer
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

)
	
end
go
exec ADWarehouse.dbo.spCleanUp_psADComputer;
go