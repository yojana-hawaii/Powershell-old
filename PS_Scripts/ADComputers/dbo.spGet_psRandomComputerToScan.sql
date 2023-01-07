
go

use ADWarehouse
go

drop proc if exists dbo.spGet_psRandomComputerToScan;
go

create proc dbo.spGet_psRandomComputerToScan
(
	@count varchar(3) = 100
)
as
begin
	declare @counter int = convert(int, @count);
	select top (@counter)
		computertype, l.sAMAccountName, l.Name, SerialNumber, ou, IPV4Address,
		
		l.LocalScanAttemptDate, 
		datediff(SECOND,l.LocalScanAttemptDate, getdate()) ScanAttemptSeconds,
		datediff(HOUR,isnull(l.LocalScanAttemptDate,''), getdate() ) ScanAttemptHours,
		
		l.LocalScanSuccessDate, 
		datediff(HOUR,l.LocalScanSuccessDate, getdate()) LastScanHours, 
		
		LastLogonDate, LastPatchDate,
		Offline,
		s.SoftwareName, active,

		--get random ordering with big priority computers not scanned yet order havent been scanned in a while
		-LOG(RAND())  / case when TpmVersion is null and l.LocalScanSuccessDate is not null then 100 else 1 end Ordering,
		RAND()  / case when l.LocalScanAttemptDate is null then 100 else 1 end Ordering2,

		-- (random number * last logon in seconds) / (last scan attempt in secondas * weight for IP null or VPN
		--isnull(
			( RAND()*  datediff(SECOND,LastLogonDate, getdate()) ) 
			/ 
			(
				isnull(datediff(SECOND,LocalScanAttemptDate, getdate()) , 8800) --never attempted then  30 min * 60
				* 
				case when IPV4Address like '10.10%' or IPV4Address is null then 1 when isnull(offline,0) = 1 then 50 else 30 end
			) 
		--, 0.5)
		Random
	from ADWarehouse.dbo.rpt_view_ADComputer l
	--from dbo.psLocalComputers l
	--	inner join dbo.psADComputers a on l.sAMAccountName = a.sAMAccountName 
		outer apply (
						select top 1 SoftwareName
						from ADWarehouse.dbo.psLocalSoftwares s1
						where s1.sAMAccountName = l.sAMAccountName
							--and SoftwareName = 'SysAid Agent'
					) s
	where 
		Name not in ('KPHC-CPSHOST01') /*IP shows 710.*/
		and LocalDetails = 1-- and Location in ('915') --and active = 0
		and 
		not (
				/*last patch is last thing I collected so wait for 7 days */
				(/*SoftwareName is not null and SoftwareName != '' and*/ SerialNumber != '' and SerialNumber is not null  )
				and datediff(DAY,isnull(l.LocalScanSuccessDate,''), convert(date,getdate())) < 7
			)
				and datediff(HOUR,isnull(l.LocalScanAttemptDate,''), getdate()) > 2
		--and vpn = 0 
		and isnull(Location,'0') != 'DMZ' --and server = 0 and VM is not null
		--and active = 1
		--and ComputerType not like '%delete%'
		--and datediff(HOUR,l.ScanAttemptDate, getdate()) > 1
		--and ScanSuccessDate is null
				
		
	order by Random , newid();

end
go

exec ADWarehouse.dbo.spGet_psRandomComputerToScan 600
go



