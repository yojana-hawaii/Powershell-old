
use ADWarehouse
go

drop proc if exists dbo.spGet_psComputersWithHPDrivers;
go

create proc dbo.spGet_psComputersWithHPDrivers
as
begin
	select  s.Name, s.SoftwareName, s.SoftwareVersion, s.SoftwareVendor, a.*
	from dbo.psLocalSoftwares s 
		inner join dbo.rpt_view_ADComputer a on a.sAMAccountName = s.sAMAccountName
	where 
		SoftwareVendor like '%hp%'
		--and name in ('710B-2FD02-22','dt-3fd02-23', 'dt-3fd01-23')
		and   (
				SoftwareName  in ('HP Scan Basic Device Software')
				or (SoftwareName like '%s3%' or SoftwareName like '%s4%')
			)
		and SoftwareName not like '%5000%'
		and a.Active = 1 --and a.LastScanDays
		
end
go

exec dbo.spGet_psComputersWithHPDrivers;
go	