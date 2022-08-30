
. "$PSScriptRoot\psTest_GetDate.ps1"
. "$PSScriptRoot\psAD_GetComputerDetails.ps1"
. "$PSScriptRoot\psHardware_GetComputerDetails.ps1"
. "$PSScriptRoot\psStoredProcedure.ps1"
. "$PSScriptRoot\psSoftware_GetDetails.ps1"
. "$PSScriptRoot\psInactive_DisableAndMoveOU.ps1"
. "$PSScriptRoot\psPrinter_GetDetails.ps1"
. "$PSScriptRoot\psMonitor_GetDetails.ps1"
. "$PSScriptRoot\psUsers_GetComputerUsers.ps1"
. "$PSScriptRoot\psAD_GetUsersAndGroups.ps1"

$gStart_time = fnTest_GetCurrentTime

<#Get Delta changes from AD and insert the changes in SQL#>
function fnLocal_ADComputersUsersAndGroups_DeltaChange {
    $deltaChangeUser = fnAD_GetUserDetails
    foreach ($user in $deltaChangeUser) {
        fnSp_InsertAdUsers($user)
    }
    $adgroups = fnAD_GetGroups
    foreach ($grp in $adgroups) {
        fnSp_InsertAdGroups($grp)
    }
    $adGroupMembers = fnAd_GetGroupMembers
    foreach ($member in $adGroupMembers) {
        fnSp_InsertAdGroupMembers($member)
    }   
    $adComp = fnAD_GetADComputerDetails
    foreach ($comp in $adComp) {
        fnSp_InsertAdComputers($comp)
    }
    fnInactive_DisableAndMoveOU
}

function fnLocal_RunHardwareStoredProc($pHardwareProperties) {
    foreach ($comp in $pHardwareProperties) {
        fnSp_InsertHardwareDetails($comp)
    }
}
function fnLocal_RunSoftwareStoredProc($pSoftwareProperties) {
    foreach ($comp in $pSoftwareProperties) {
        fnSp_InsertSoftwareDetails($comp)
    }
}
function fnLocal_RunPrinterStoredproc($PrinterProperties) {
    foreach ($comp in $PrinterProperties) {
        fnSp_InsertPrinterDetails($comp)
    }
}
<# Get hardware, software, printer, monitor and logged in users #>
function fnLocal_ScanComputers($pComputeList) {
    $total = $pComputeList.Count
    $counter = 1

    foreach ($comp in $pComputeList) {
        write-host "Working on ", $comp.Name, "...", $counter, "of", $total
        $HardwareProperties = fnHardware_GetLocalComputerDetails($comp)
        fnLocal_RunHardwareStoredProc($HardwareProperties)

        $SoftwareProperties = fnSoftware_GetLocalDetailsRegistry($comp)
        fnLocal_RunSoftwareStoredProc($SoftwareProperties)
        
        $PrinterProperties = fnPrinter_GetDetails($comp)
        fnLocal_RunPrinterStoredproc($PrinterProperties)

        fnMonitor_GetMonitorDetails($comp)
        fnUser_GetUserLoggedOnHistory($comp)
        $counter++
    }
}
<# If computerList not null -> use the list provided
if computerList is null -> stored proc to get unscanned computer#>
function fnLocal_ScanListOfComputer($computerList){
    if ( $null -ne $computerList) {
        $unscannedComputers = fnAD_GetADPropertiesSelectComputers($computerList)
        fnLocal_ScanComputers($unscannedComputers)
    }
    else {
        $randomComputers = fnSp_GetRandomUnscannedComputers
        fnLocal_ScanComputers($randomComputers)
    }
}
function fnLocal_Main($computerList) {
    fnLocal_ADComputersUsersAndGroups_DeltaChange
    fnLocal_ScanListOfComputer -computerList $computerList   
    fnSp_CleanUpTables 
}


$gEnd_time = fnTest_GetCurrentTime
$gDuration = $gEnd_time - $gStart_time
Write-Host "Start: " $gStart_time ", End: " $gEnd_time ", Total time: " $gDuration.TotalMinutes
