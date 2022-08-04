
go

use ADWarehouse
go

drop proc if exists dbo.spGet_psRandomComputerToScan;
go

create proc dbo.spGet_psRandomComputerToScan
(
	@count varchar(3) = 50
)
as
begin
	declare @counter int = convert(int, @count);
	select top (@counter)
		computertype, l.sAMAccountName, l.Name, SerialNumber, ou, IPV4Address,
		
		l.ScanAttemptDate, 
		datediff(SECOND,l.ScanAttemptDate, getdate()) ScanAttemptSeconds,
		
		l.ScanSuccessDate, 
		datediff(HOUR,l.ScanSuccessDate, getdate()) LastScanHours, 
		
		LastLogonDate, LastPatchDate,
		Offline,
		s.SoftwareName,

		--get random ordering with big priority computers not scanned yet order havent been scanned in a while
		-LOG(RAND())  / case when TpmVersion is null and l.ScanSuccessDate is not null then 100 else 1 end Ordering,
		RAND()  / case when l.ScanAttemptDate is null then 100 else 1 end Ordering2,

		-- (random number * last logon in seconds) / (last scan attempt in secondas * weight for IP null or VPN
		( RAND()*  datediff(SECOND,LastLogonDate, getdate()) ) / (datediff(SECOND,ScanAttemptDate, getdate()) * case when  IPV4Address is null then 1 else 100 end)  Random
	from ADWarehouse.dbo.rpt_view_ADComputer l
	--from dbo.psLocalComputers l
	--	inner join dbo.psADComputers a on l.sAMAccountName = a.sAMAccountName 
		outer apply (
						select top 1 SoftwareName
						from ADWarehouse.dbo.psLocalSoftwares s1
						where s1.sAMAccountName = l.sAMAccountName
					) s
	where 
		LocalDetails = 1 
		and 
		not (
				/*last patch is last thing I collected so wait for 7 days */
				(SoftwareName is not null and SoftwareName != '' and SerialNumber != '' and SerialNumber is not null  )
				and datediff(DAY,l.ScanSuccessDate, convert(date,getdate())) < 7
			)
		--and vpn = 0 
		and isnull(Location,'0') != 'DMZ' --and server = 0 and VM is not null
		--and datediff(HOUR,l.ScanAttemptDate, getdate()) > 1
		--and ScanSuccessDate is null
				
		
	order by Random
	--order by newid();

end
go

exec ADWarehouse.dbo.spGet_psRandomComputerToScan 5
go



