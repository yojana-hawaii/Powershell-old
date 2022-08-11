
. "$PSScriptRoot\psTest_GetDate.ps1"
. "$PSScriptRoot\psAD_GetComputerDetails.ps1"
. "$PSScriptRoot\psHardware_GetComputerDetails.ps1"
. "$PSScriptRoot\psStoredProcedure.ps1"
. "$PSScriptRoot\psSoftware_GetDetails.ps1"
. "$PSScriptRoot\psInactive_DisableAndMoveOU.ps1"
. "$PSScriptRoot\psPrinter_GetDetails.ps1"
. "$PSScriptRoot\psMonitor_GetDetails.ps1"

$gStart_time = fnTest_GetCurrentTime

function fnLocal_RunADStoredProc($pADComputerProperties){
     foreach($comp in $ADComputersProperties){
            fnSp_InsertAdComputers($comp)
        }
        fnSp_CleanUpAdComputers
}
function fnLocal_RunHardwareStoredProc($pHardwareProperties){
    foreach($comp in $pHardwareProperties){
        fnSp_InsertHardwareDetails($comp)
    }
       fnSp_CleanUpHardwareDetails
}
function fnLocal_RunSoftwareStoredProc($pSoftwareProperties){
    foreach($comp in $pSoftwareProperties){
        fnSp_InsertSoftwareProc($comp)
    }
    #    fnSp_CleanUpSoftwareDetails
}
function fnLocal_RunPrinterStoredproc($PrinterProperties){
    foreach($comp in $PrinterProperties){
        fnSp_InsertPrinterDetails($comp)
    }
    #    fnSp_CleanUpPrinterDetails
}
function fnLocal_ComputersToScan($pComputeList){
    $total = $pComputeList.Count
    $counter = 1

    foreach($comp in $pComputeList){
        write-host "Working on ", $comp.Name, "...", $counter, "of", $total
        $HardwareProperties = fnHardware_GetLocalComputerDetails($comp)
        fnLocal_RunHardwareStoredProc($HardwareProperties)
        $SoftwareProperties = fnSoftware_GetLocalDetailsRegistry($comp)
        fnLocal_RunSoftwareStoredProc($SoftwareProperties)
        
        $PrinterProperties = fnPrinter_GetDetails($comp)
        fnLocal_RunPrinterStoredproc($PrinterProperties)

        fnMonitor_GetMonitorDetails($comp)
        $counter++
    }
}
function fnLocal_Main($computerList){
    
    <#Run AD part only it is 11pm#>
    $time  = Get-Date -Format "HH:mm" 
    if ($time -like "23*" -and (get-date).DayOfWeek -eq "Sunday"){
        if( $null -eq $computerList){
            $ADComputersProperties = fnAD_GetADComputerDetails
        }
        fnLocal_RunADStoredProc($ADComputersProperties)       
        fnInactive_DisableAndMoveOU
    }
    
    <#if not null use computer from the list provided
    if null then stored proc to get computer list#>
    if( $null -ne $computerList){
        $ADComputers = fnAD_GetManualComputerDetails($computerList)
        fnLocal_ComputersToScan($ADComputers)
    } else {
        $randomComputers =  fnSp_GetRandomComputersUsingStoredProc
        fnLocal_ComputersToScan($randomComputers)
    }
    
}

$gEnd_time = fnTest_GetCurrentTime
$gDuration = $gEnd_time - $gStart_time
Write-Host "Start: " $gStart_time ", End: " $gEnd_time ", Total time: " $gDuration.TotalMinutes
