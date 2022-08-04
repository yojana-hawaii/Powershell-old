. "$PSScriptRoot\psConfig.ps1"
. "$PSScriptRoot\psAD_GetComputerDetails.ps1"

function fnLocal_MoveOU($inactiveList, $ou){
    foreach ($comp in $inactiveList) {
        Get-ADComputer -Identity $comp.Name | Set-ADObject -ProtectedFromAccidentalDeletion $false
        Get-ADComputer -Identity $comp.Name | Move-ADObject -TargetPath $ou
        Get-ADComputer -Identity $comp.Name | Set-ADObject -ProtectedFromAccidentalDeletion $true
    }
}
function fnInactive_DisableAndMoveOU{

    $disabledServer = fnConfig_GetInactiveServerOU
    $365Plus = fnConfig_GetInactive365PlusOU
    $180Plus = fnConfig_GetInactive180PlusOU
    $90Plus = fnConfig_GetInactive90PlusOU
    $30Plus = fnConfig_GetInactive30PlusOU
    $14Plus = fnConfig_GetInactive14PlusOU

    write-host $365Plus
    $Inactive365 = fnAD_GetInactiveComputers  -startDay 153982 -endDay  365
    fnLocal_MoveOU -inactiveList $Inactive365 -ou $365Plus
    
    write-host $180Plus
    $Inactive180 = fnAD_GetInactiveComputers  -startDay 365 -endDay  180
    fnLocal_MoveOU -inactiveList $Inactive180 -ou $180Plus
    
    write-host $90Plus
    $Inactive90 = fnAD_GetInactiveComputers  -startDay 180 -endDay  90
    fnLocal_MoveOU -inactiveList $Inactive90 -ou $90Plus
    
    write-host $30Plus
    $Inactive30 = fnAD_GetInactiveComputers  -startDay 90 -endDay  30
    fnLocal_MoveOU -inactiveList $Inactive30 -ou $30Plus

    write-host $14Plus
    $Inactive30 = fnAD_GetInactiveComputers  -startDay 30 -endDay  14
    fnLocal_MoveOU -inactiveList $Inactive30 -ou $14Plus
}