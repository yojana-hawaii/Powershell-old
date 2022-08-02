
. "$PSScriptRoot\psTest_GetDate.ps1"
. "$PSScriptRoot\psAD_GetComputerDetails.ps1"

$gStart_time = fnTest_GetCurrentTime


# fnAD_GetADComputerDetails

$computerList = "ayush-vm,aashish-21"
fnAD_GetManualComputerDetails($computerList)

$gEnd_time = fnTest_GetCurrentTime
$gDuration = $gEnd_time - $gStart_time
Write-Host "Start: " $gStart_time ", End: " $gEnd_time ", Total time: " $gDuration.TotalMinutes
