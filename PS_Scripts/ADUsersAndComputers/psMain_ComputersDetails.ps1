
. "$PSScriptRoot\psTest_GetDate.ps1"

$gStart_time = fnTest_GetCurrentTime




$gEnd_time = fnTest_GetCurrentTime
$gDuration = $gEnd_time - $gStart_time
Write-Host "Start: " $gStart_time ", End: " $gEnd_time ", Total time: " $gDuration.TotalMinutes
