
. "$PSScriptRoot\psTest_GetDate.ps1"
. "$PSScriptRoot\psAD_GetComputerDetails.ps1"
. "$PSScriptRoot\psHardware_GetComputerDetails.ps1"
. "$PSScriptRoot\psStoredProcedure.ps1"

$gStart_time = fnTest_GetCurrentTime

function fnLocal_RunADStoredProc($pADComputerProperties){
     foreach($comp in $ADComputersProperties){
            fnSp_InsertAdComputers($comp)
        }
    
        fnSp_CleanUpAdComputers
        #run script to move computer name to local computer data table
}
function fnLocal_Main($computerList){
    if( $null -ne $computerList){
        $ADComputersProperties = fnAD_GetManualComputerDetails($computerList)
        $HardwareProperties = fnHardware_GetManualComputerDetails($ADComputersProperties)
    }
    
    <#Run AD part only it is 11pm#>
    $time  = Get-Date -Format "HH:mm" 
    if ($time -like "23*"){
        if( $null -eq $computerList){
            $ADComputersProperties = fnAD_GetADComputerDetails
        }
        fnLocal_RunADStoredProc($ADComputersProperties)       
    }
    
    return $HardwareProperties
}



$computerList = $null


$computerList = "comp1,comp2,server1,server2"


fnLocal_Main($computerList)

$gEnd_time = fnTest_GetCurrentTime
$gDuration = $gEnd_time - $gStart_time
Write-Host "Start: " $gStart_time ", End: " $gEnd_time ", Total time: " $gDuration.TotalMinutes
