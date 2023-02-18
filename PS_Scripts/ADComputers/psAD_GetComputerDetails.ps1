
. "$PSScriptRoot\psConfig.ps1"
function fnLocal_Getwin10version($pVersionNumber){
    $lWin10Version = ''
    switch ($pVersionNumber) {
        '10.0 (22621)' {  $lWin10Version = 'Win11 22H2'; break }
        '10.0 (22000)' {  $lWin10Version = 'Win11 21H2'; break }
        '10.0 (19045)' {  $lWin10Version = 'Win10 22H2'; break }
        '10.0 (19044)' {  $lWin10Version = 'Win10 21H2'; break }
        '10.0 (19043)' {  $lWin10Version = 'Win10 21H1'; break }
        '10.0 (19042)' {  $lWin10Version = 'Win10 20H2'; break }
        '10.0 (19041)' {  $lWin10Version = 'Win10 20H1'; break }
        '10.0 (18363)' {  $lWin10Version = 'Win10 19H2'; break }
        '10.0 (18362)' {  $lWin10Version = 'Win10 19H1'; break }
        '10.0 (17763)' {  $lWin10Version = 'Win10 1809'; break }
        '10.0 (17134)' {  $lWin10Version = 'Win10 1803'; break }
        '10.0 (16299)' {  $lWin10Version = 'Win10 1709'; break }
        '10.0 (15063)' {  $lWin10Version = 'Win10 1703'; break }
        '10.0 (14393)' {  $lWin10Version = 'Win10 1607'; break }
        '10.0 (10586)' {  $lWin10Version = 'Win10 1511'; break }
        '10.0 (10240)' {  $lWin10Version = 'Win10 1507'; break }
        Default { $lWin10Version = $pVersionNumber }
    }
    return $lWin10Version
}
function fnLocal_OrganizeADProperties($pComputerList){
    $properties = $pComputerList  | 
                Select-Object Name, DistinguishedName, Created, Modified, UserAccountControl, sAMAccountName, `
                    IPV4Address, LastLogonDate, LogonCount, `
                    @{name="Description"; Expression={$_.Description.replace("'","")} }, `
                    # @{name="OU"; Expression={fnLocal_GetOU($_.DistinguishedName)} }, `
                    @{name="OU"; Expression={$_.CanonicalName } }, `
                    @{name="Active"; Expression={if ($_.Enabled) {1} else {0} } },`
                    @{name="Server"; Expression={if ($_.OperatingSystem -like '*server*' ) {1} else {0} } },`
                    @{name="Thin_Client"; Expression={if ($_.OperatingSystem -like "*LTSC*" -and $_.Name -notlike '*POS*') {1} else {0} } }, `
                    @{name="BitLockerPasswordDate"; Expression={Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation' " -SearchBase $_.DistinguishedName -Properties whenCreated |
                                                                         Sort-Object whenCreated -Descending | 
                                                                         Select-Object -First 1 | 
                                                                         Select-Object -ExpandProperty whenCreated} }, `
                    OperatingSystem, OperatingSystemVersion, `
                    @{name = 'OSVersion'; Expression= {fnLocal_Getwin10version($_.OperatingSystemVersion)} }
                    
    return $properties
}


function fnAD_GetADComputerDetails{
    $dc = fnConfig_GetPrimaryDC
    $date = (Get-Date).AddDays(-1)

    write-host "Getting list of all computers from " $dc
    $adProperties = Get-ADComputer -Filter {whenChanged -gt $date }  -Properties * -server $dc #-ResultSetSize 20
    $adProperties = fnLocal_OrganizeADProperties($adProperties)

    return $adProperties
 
}

function fnAD_GetADPropertiesSelectComputers($pComputerList){
    $tempProperties = @()
    $computers = $pComputerList.split(",")
    foreach($comp in $computers){
        $tempProperties += Get-ADComputer -Identity $comp -Properties * 
        $adProperties = fnLocal_OrganizeADProperties($tempProperties)
    }

    return $adProperties
}

function fnAD_GetDisabledComputerOver365Days{
    $365Plus = fnConfig_GetInactive365PlusOU
    $startDay = 153982 
    $endDay = 366
    $startDate = (Get-Date).AddDays(-($startDay) ) 
    $Endate = (Get-Date).AddDays(-($endDay) )
    $365Plus_list = Get-ADComputer -Filter {LastLogonTimeStamp -gt $startDate -and LastLogonTimeStamp -le $Endate } -SearchBase $365Plus | 
                        Where-Object {$_.Enabled -eq $false} | 
                        Select-Object Name, LastLogonTimeStamp, LastLogonDate,DistinguishedName
    return $365Plus_list
}

function fnAD_GetInactiveComputers($startDay, $endDay){
    
    $startDate = (Get-Date).AddDays(-($startDay) ) 
    $Endate = (Get-Date).AddDays(-($endDay) ) 
    Write-Host $startDay $endDay
    write-host $startDate $Endate
    $OUs = fnConfig_GetWorkstationOU
    $remoteOu = fnConfig_GetRemoteOU
    $outoNetworkOU = fnConfig_GetOutofNetworkOU
    $thinOU = fnConfig_GetThinClientOU
    $PSCustom_CompDetails = @()

    foreach($ou in $OUs){

        $inactiveList = Get-ADComputer  `
                -Filter {LastLogonTimeStamp -gt $startDate -and LastLogonTimeStamp -le $Endate } `
                -SearchBase $ou | 
                    Where-Object {$_.DistinguishedName -notlike $outoNetworkOU `
                                    -and $_.DistinguishedName -notlike $remoteOu `
                                    -and $_.DistinguishedName -notlike $thinOU `
                                    # -and $_.Enabled -eq $true -> need to move inactive computers as well
                                } |
                    Select-Object Name, LastLogonTimeStamp, LastLogonDate,DistinguishedName
    
        foreach ($comp in $inactiveList){
    
            $PSCustom_CompDetails += [PSCustomObject]@{
                Name = $comp.name
                DistinguishedName = $comp.DistinguishedName
            }
        }
    }
    write-host "total" $inactiveList.count
    return $PSCustom_CompDetails
}
# fnAD_GetInactiveComputers -startDay 365 -endDay 14
