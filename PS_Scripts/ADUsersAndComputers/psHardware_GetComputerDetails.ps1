
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
function fnLocal_GetLocalComputerDetails($pComputer){
    $localCompName = $pComputer.Name
    $lComputerSMA = $pComputer.sAMAccountName
   
    $ping = Test-Connection $localCompName -Quiet -Count 1
    if($ping) {
        write-host "Ping success"

        $securityPatch = Get-HotFix -Description Security* -ComputerName $localCompName | Sort-Object InstalledOn -Descending | Select-Object -First 1 
        $AnyPatch = Get-HotFix  -ComputerName $localCompName | Sort-Object InstalledOn -Descending | Select-Object -First 1 
        write-host "patch complete"

        $PSCustom_CompDetails = @()
        $PSCustom_CompDetails = [PSCustomObject]@{
            Name = $localCompName
            sAMAccountName = $lComputerSMA

            Last_Security_KB = $securityPatch.HotFixID
            Last_SecurityPatch_date = $securityPatch.InstalledOn
            LastPatchKb = $AnyPatch.HotFixID
            LastPatchDate = $AnyPatch.InstalledOn

            Print_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "Spooler"
            Kace_status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "konea"
            Sentinel_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "SysAidAgent"
            Sysaid_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "SentinelAgent"
            DellEncryption_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "DellMgmtAgent"
            Cylance_Status = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "CylanceSvc"

            IsLaptop = fnLocal_isLaptop($localCompName)
        } 
    }

    
    return $PSCustom_CompDetails
}
function fnHardware_GetManualComputerDetails($pComputerList){
    
    $pComputerList
    $total = $pComputerList.Count
    $counter = 1
    foreach($comp in $pComputerList){
        write-host "Working on ", $comp.Name, "...", $counter, "of", $total
        $hdDetails = fnLocal_GetLocalComputerDetails($comp)
        $counter++
    }
    return $hdDetails
}