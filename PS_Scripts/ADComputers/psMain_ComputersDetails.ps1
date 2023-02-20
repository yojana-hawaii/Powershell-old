
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
$gHour = Get-Date -UFormat "%H"


function fnLocal_DeleteComputersNotInAD {

    $computerList = fnSp_GetPossibleDeletedComputers
    
    foreach($comp in $computerList){
        $compName = $comp.Name
        Write-Host $compName
        try{
            Get-ADComputer $compName -ErrorAction Stop
            Write-Host "found"
        }
        catch {
            Write-Host "not found -> Delete"
            fnSp_DeleteComputersNotInAD -pADDetails $comp
        }
    }
}

function fnLocal_AdGroups{
    $adgroups = fnAD_GetGroups
    foreach ($grp in $adgroups) {
        fnSp_InsertAdGroups($grp)
    }
    $adGroupMembers = fnAd_GetGroupMembers
    foreach ($member in $adGroupMembers) {
        fnSp_InsertAdGroupMembers($member)
    }   
    
}
function fnLocal_AdComputers{
    $adComp = fnAD_GetADComputerDetails
    foreach ($comp in $adComp) {
        fnSp_InsertAdComputers($comp)
    }
}
function fnLocal_AdUSers{
    $deltaChangeUser = fnAD_GetUserDetails
    foreach ($user in $deltaChangeUser) {
        fnSp_InsertAdUsers($user)
    }

}
<#Get Delta changes from AD and insert the changes in SQL#>
function fnLocal_ADComputersUsersAndGroups_DeltaChange {

    if ( $gHour % 2 -eq 0){fnLocal_AdUSers} else {write-host "AD Users update -> not even hours"}
    if ( $gHour -eq 18){fnLocal_AdComputers} else {write-host "AD computers update -> not 6pm"}
    if ( $gHour -eq 19){fnLocal_AdGroups} else {write-host "AD groups update -> not 7pm"}
    if ( $gHour -eq 20){fnInactive_DisableAndMoveOU} else {write-host "AD move -> not 8pm"}
    if ( $gHour -eq 21){fnLocal_DeleteComputersNotInAD} else {write-host "Delete Computer -> not 9pm"}
    if ( $gHour -eq 22){fnInactive_RemoveProtection} else {write-host "Remove Protection -> not 10pm"}

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
