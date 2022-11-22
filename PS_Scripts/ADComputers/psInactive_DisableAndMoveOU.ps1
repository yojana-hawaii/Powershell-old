. "$PSScriptRoot\psConfig.ps1"
. "$PSScriptRoot\psAD_GetComputerDetails.ps1"

function fnLocal_MoveOU($inactiveList, $ou){
    foreach ($comp in $inactiveList) {
        Write-Host $comp.name $comp.DistinguishedName
        Get-ADComputer -Identity $comp.Name | Set-ADObject -ProtectedFromAccidentalDeletion $false
        Get-ADComputer -Identity $comp.Name | Move-ADObject -TargetPath $ou
        Get-ADComputer -Identity $comp.Name | Set-ADObject -ProtectedFromAccidentalDeletion $true
    }
}
function fnLocal_DisableComputers($inactiveList){
    foreach ($comp in $inactiveList) {
        Get-ADComputer -Identity $comp.Name | Disable-ADAccount -PassThru
    }
}
function fnInactive_DisableAndMoveOU{
    write-host $365Plus
    $Inactive365 = fnAD_GetInactiveComputers  -startDay 153982 -endDay  365
    fnLocal_MoveOU -inactiveList $Inactive365 -ou $365Plus
    fnLocal_DisableComputers($Inactive365)

    write-host $180Plus
    $Inactive180 = fnAD_GetInactiveComputers  -startDay 365 -endDay  180
    fnLocal_MoveOU -inactiveList $Inactive180 -ou $180Plus
    fnLocal_DisableComputers($Inactive180)
    
    write-host $90Plus
    $Inactive90 = fnAD_GetInactiveComputers  -startDay 180 -endDay  90
    fnLocal_MoveOU -inactiveList $Inactive90 -ou $90Plus
    fnLocal_DisableComputers($Inactive90)
    
    write-host $60Plus
    $Inactive60 = fnAD_GetInactiveComputers  -startDay 90 -endDay  60
    fnLocal_MoveOU -inactiveList $Inactive30 -ou $60Plus
    fnLocal_DisableComputers($Inactive60)

    write-host $30Plus
    $Inactive30 = fnAD_GetInactiveComputers  -startDay 60 -endDay  30
    fnLocal_MoveOU -inactiveList $Inactive30 -ou $30Plus

    # write-host $14Plus
    # $Inactive14 = fnAD_GetInactiveComputers  -startDay 30 -endDay  14
    # fnLocal_MoveOU -inactiveList $Inactive14 -ou $14Plus
}

function fnInactive_ManualDisableAndMove($pComputer){
    $localCompName = $pComputer.Name
    # $lComputerSMA = $pComputer.sAMAccountName
    $startDay = 14
    $startDate = (Get-Date).AddDays(-($startDay) ) 
    $Inactive14 = Get-ADComputer -Identity $localCompName -Properties * | Select-Object Name,DistinguishedName, LastLogonDate, @{name="inactive"; Expression={$_.LastLogonDate -le $startDate -and $_.OperatingSystem -notlike '*server*'};}
    Write-Host $tempProperties
    fnLocal_MoveOU -inactiveList $Inactive14 -ou $14Plus
    # return $adProperties?
}
    # $disabledServer = fnConfig_GetInactiveServerOU
    $365Plus = fnConfig_GetInactive365PlusOU
    $180Plus = fnConfig_GetInactive180PlusOU
    $90Plus = fnConfig_GetInactive90PlusOU
    $60Plus = fnConfig_GetInactive60PlusOU
    $30Plus = fnConfig_GetInactive30PlusOU
    # $14Plus = fnConfig_GetInactive14PlusOU

    # fnInactive_DisableAndMoveOU
