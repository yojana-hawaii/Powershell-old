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
function fnLocal_GetLocalComputerDetails($pComputer){
    $localCompName = $pComputer.Name
    $lComputerSMA = $pComputer.sAMAccountName
   
    $ping = Test-Connection $localCompName -Quiet -Count 1
    if($ping) {
        write-host "Ping success"

        $securityPatch = Get-HotFix -Description Security* -ComputerName $localCompName | Sort-Object InstalledOn -Descending | Select-Object -First 1 
        $AnyPatch = Get-HotFix  -ComputerName $localCompName | Sort-Object InstalledOn -Descending | Select-Object -First 1 
        write-host "patch complete"

        $print_service = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "Spooler"
        $kace_service = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "konea"
        $sysaid_service = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "SysAidAgent"
        $sentinel_service = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "SentinelAgent"
        $dellEncryption_service = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "DellMgmtAgent"
        $cylance_service = fnLocal_GetServiceStatus -pComputerName $localCompName -pServiceName "CylanceSvc"
        write-host "service complete"
    }

    $PSCustom_CompDetails = @()
    $PSCustom_CompDetails = [PSCustomObject]@{
        Name = $localCompName
        sAMAccountName = $lComputerSMA

        Last_Security_KB = $securityPatch.HotFixID
        Last_SecurityPatch_date = $securityPatch.InstalledOn
        LastPatchKb = $AnyPatch.HotFixID
        LastPatchDate = $AnyPatch.InstalledOn

        Print_Status = $print_service
        Kace_status = $kace_service
        Sentinel_Status = $sentinel_service
        Sysaid_Status = $sysaid_service
        DellEncryption_Status = $dellEncryption_service
        Cylance_Status = $cylance_service
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