
. "$PSScriptRoot\psTest_GetDate.ps1"
. "$PSScriptRoot\psAD_GetComputerDetails.ps1"
. "$PSScriptRoot\psStoredProcedure.ps1"

$gStart_time = fnTest_GetCurrentTime

function fnLocal_Main($computerList){
    if( $null -eq $computerList){
        $ADComputersProperties = fnAD_GetADComputerDetails
    } else {
        $ADComputersProperties = fnAD_GetManualComputerDetails($computerList)
    }

    foreach($comp in $ADComputersProperties){
        fnSp_InsertAdComputers($comp)
    }

    #run script to clean up AD Computers dates and move computer name to local computer data table
}



$computerList = $null


# $computerList = "ayush-vm,aashish-21"

fnLocal_Main($computerList)

$gEnd_time = fnTest_GetCurrentTime
$gDuration = $gEnd_time - $gStart_time
Write-Host "Start: " $gStart_time ", End: " $gEnd_time ", Total time: " $gDuration.TotalMinutes
