
function fnLocal_GetServiceStatus{
    param($pComputerName, $pServiceName)
    try {
        $service = (Get-Service -ComputerName $pComputerName -Name $pServiceName  -ErrorAction Stop).Status
    } catch {
        $service = "missing"
        write-host $pComputerName "missing" $pServiceName
    }
    return $service
}
function fnLocal_isLaptop($ComputerName){

    $isLaptop = 0
    $chasis_type = Get-WmiObject -class win32_systemenclosure -computerName $ComputerName | select-object chassistypes
    $battery = Get-WmiObject -class win32_battery -ComputerName $ComputerName 
    # $battery

    if ($chasis_type.chassistypes -eq 9 -or $chasis_type.chassistypes -eq 10 -or $chasis_type.chassistypes -eq 14 -or $battery ){
        $isLaptop = 1
    }
    
    return $isLaptop
}
function fnLocal_WakupTpye($pWakeupCode){
    $wake = ''
        switch($pWakeupCode){
            0 {$wake = 'Reserved'; break} 
            1 {$wake = 'Other'; break} 
            2 {$wake = 'Unknown'; break} 
            3 {$wake = 'APM Timer'; break} 
            4 {$wake = 'Modem Ring'; break} 
            5 {$wake = 'LAN Remote'; break} 
            6 {$wake = 'Power Switch'; break} 
            7 {$wake = 'PCI PME#'; break}
            8 {$wake = 'AC Power Restored'; break} 

            Default {$wake = $pWakeupCode} 

        }
    return $wake
}
function fnLocal_GetDiskType($pDiskType){
    $disk = ''
        switch($pDiskType){
            3 {$disk = 'HDD'}
            4 {$disk = 'SDD'}
            5 {$disk = 'SCM'}
            Default {$disk = $DiskType}
        }
    return $disk
}
function fnHardware_GetLocalComputerDetails($pComputer){
    $localCompName = $pComputer.Name
    $lComputerSMA = $pComputer.sAMAccountName
   
    $ping = Test-Connection $localCompName -Quiet -Count 1
    if($ping) {
        write-host "Ping success"

        try {
            $securityPatch = Get-HotFix -Description Security* -ComputerName $localCompName | Sort-Object InstalledOn -Descending | Select-Object -First 1 
            $AnyPatch = Get-HotFix  -ComputerName $localCompName | Sort-Object InstalledOn -Descending | Select-Object -First 1 
            write-host "patch complete"
        }catch{
            write-host "patch detail failed"
        }

        try {
            $bios_class = Get-WmiObject -ClassName win32_bios -ComputerName $localCompName | Select-Object SerialNumber, SMBIOSBIOSVersion, ReleaseDate
            $computerSystem_class = Get-WmiObject -ClassName win32_computersystem -ComputerName $localCompName | Select-Object Manufacturer, Model, TotalPhysicalMemory,UserName,WakeUpType
            $processor_class = Get-WmiObject -ClassName win32_processor -ComputerName $localCompName | Select-Object Name
            $os_class = Get-WmiObject -ClassName win32_operatingsystem -ComputerName $localCompName | Select-Object LastBootUpTime, EncryptionLevel, NumberOfUsers,OSArchitecture
            $disk_class = Get-WmiObject -ClassName Win32_DiskDrive -ComputerName $localCompName | select-object Model, @{Name = "HDD_Size_GB"; Exp={$_.Size / 1Gb -as [int]}}
            $physicalDisk_class = Get-WmiObject -ClassName MSFT_PhysicalDisk -ComputerName $localCompName -Namespace root\Microsoft\Windows\Storage  | Select-Object MediaType
            $tpm_class = Get-WmiObject -ClassName Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $localCompName -Authentication PacketPrivacy | Select-Object IsEnabled_InitialValue, SpecVersion
            $physicalMemoryArray = Get-WmiObject -Class win32_physicalmemoryArray -computername $localCompName | Select-Object maxCapacityEx, MemoryDevices
            $physicalMemory = Get-WmiObject -Class win32_physicalmemory -computername $localCompName | Select-Object *
            write-host "WMI complete"
        } catch {
            Write-Host "WMI Failed"
        }

        $path = "\\" + $localCompName + "\C$\Windows\System32\"
        $localspl = $path + "localspl.dll"
        $spoolsv = $path + "spoolsv.exe"
        $win32spl =  $path + "win32spl.dll"

        $dell_old = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "DellMgmtAgent"
        $dell_new = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "CMGShield"
        $dell = "missing"
        if ($dell_new -eq "running") {$dell = "Running new"} 
        if ($dell_old -eq "running") {$dell = "Running old"}

        $PSCustom_CompDetails = @()
        $PSCustom_CompDetails = [PSCustomObject]@{
            Name = $localCompName
            sAMAccountName = $lComputerSMA

            Offline = 0

            Last_Security_KB = $securityPatch.HotFixID
            Last_SecurityPatch_date = $securityPatch.InstalledOn
            LastPatchKb = $AnyPatch.HotFixID
            LastPatchDate = $AnyPatch.InstalledOn

            Print_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "Spooler"
            Kace_status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "konea"
            Sentinel_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "SysAidAgent"
            Sysaid_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "SentinelAgent"
            DellEncryption_Status =  $dell
            Cylance_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "CylanceSvc"

            IsLaptop = fnLocal_isLaptop($localCompName)

            SerialNumber = $bios_class.SerialNumber
            BiosVersion = $bios_class.SMBIOSBIOSVersion
            BiosReleaseDate  = [Management.ManagementDateTimeConverter]::ToDateTime($bios_class.ReleaseDate)

            Manufacturer = $computerSystem_class.Manufacturer
            Model = $computerSystem_class.Model
            RAM_GB = [MATH]::Round( ($computerSystem_class.TotalPhysicalMemory / 1Gb), 2 )
            TotalRamSlot = $physicalMemoryArray.MemoryDevices
            RamSlotUsed = if($null -eq $physicalMemory.count){1} else {$physicalMemory.count}
            # RamUpgradeAvailable = [MATH]::Round( ($RamUpgradeAvailable.maxCapacityEx / 1Gb), 2 )
            VM = if ($computerSystem_class.Model -like 'virtual*' -or $computerSystem_class.Model -like "VMWare*") {1} else {0}
            CurrentUser = $computerSystem_class.UserName
            WakeUpType = fnLocal_WakupTpye($computerSystem_class.WakeUpType)
            
            Processor = $processor_class.Name

            LastReboot  = [Management.ManagementDateTimeConverter]::ToDateTime($os_class.LastBootUpTime)
            EncryptionLevel = $os_class.EncryptionLevel
            NumberOfUsers = $os_class.NumberOfUsers
            OSArchitecture = $os_class.OSArchitecture

            Disk_Model = $disk_class.Model
            Disk_Size_GB = $disk_class.HDD_Size_GB

            Disk_Type = fnLocal_GetDiskType($physicalDisk_class.MediaType)

            TpmEnabled = $tpm_class.IsEnabled_InitialValue
            TpmVersion = $tpm_class.SpecVersion

            LocalSpl_Date = (get-item $localspl | Select-Object LastWriteTime).LastWriteTime  
            SpoolSv_Date = (get-item $spoolsv | Select-Object LastWriteTime).LastWriteTime
            Win32Spl_Date = (get-item $win32spl | Select-Object LastWriteTime).LastWriteTime
        } 
    } else {
        write-host "ping failed"
        $PSCustom_CompDetails = [PSCustomObject]@{
            Name = $localCompName
            sAMAccountName = $lComputerSMA

            Offline = 1
        }
    }

    
    return $PSCustom_CompDetails
}
