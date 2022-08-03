
function fnLocal_GetLocalComputerDetails($pComputer){
    $localCompName = $pComputer.Name
    $lComputerSMA = $pComputer.sAMAccountName
   
    $ping = Test-Connection $localCompName -Quiet -Count 1
    if($ping) {
        write-host "Ping success"

        $securityPatch = Get-HotFix -Description Security* -ComputerName $localCompName | Sort-Object InstalledOn -Descending | Select-Object -First 1 
        $AnyPatch = Get-HotFix  -ComputerName $localCompName | Sort-Object InstalledOn -Descending | Select-Object -First 1 
        write-host "patch complete"
    }

    $PSCustom_CompDetails = @()
    $PSCustom_CompDetails = [PSCustomObject]@{
        Name = $localCompName
        sAMAccountName = $lComputerSMA

        Last_Security_KB = $securityPatch.HotFixID
        Last_SecurityPatch_date = $securityPatch.InstalledOn
        LastPatchKb = $AnyPatch.HotFixID
        LastPatchDate = $AnyPatch.InstalledOn
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