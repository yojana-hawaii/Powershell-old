
. "$PSScriptRoot\psConfig.ps1"
function fnLocal_Getwin10version($pVersionNumber){
    $lWin10Version = ''
    switch ($pVersionNumber) {
        '10.0 (19044)' {  $lWin10Version = '21H2'; break }
        '10.0 (19043)' {  $lWin10Version = '21H1'; break }
        '10.0 (19042)' {  $lWin10Version = '20H2'; break }
        '10.0 (19041)' {  $lWin10Version = '20H1'; break }
        '10.0 (18363)' {  $lWin10Version = '19H2'; break }
        '10.0 (18362)' {  $lWin10Version = '19H1'; break }
        '10.0 (17763)' {  $lWin10Version = '1809'; break }
        '10.0 (17134)' {  $lWin10Version = '1803'; break }
        '10.0 (16299)' {  $lWin10Version = '1709'; break }
        '10.0 (15063)' {  $lWin10Version = '1703'; break }
        '10.0 (14393)' {  $lWin10Version = '1607'; break }
        '10.0 (10586)' {  $lWin10Version = '1511'; break }
        '10.0 (10240)' {  $lWin10Version = '1507'; break }
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

    write-host "Getting list of all computers from " $dc
    $adProperties = Get-ADComputer -Filter *  -Properties * -server $dc #-ResultSetSize 20
    $adProperties = fnLocal_OrganizeADProperties($adProperties)

    return $adProperties
 
}
function fnAD_GetManualComputerDetails($pComputerList){
    $tempProperties = @()
    $computers = $pComputerList.split(",")
    foreach($comp in $computers){
        $tempProperties += Get-ADComputer -Identity $comp -Properties * 
        $adProperties = fnLocal_OrganizeADProperties($tempProperties)
    }

    return $adProperties
}

function fnAD_GetInactiveComputers($startDay, $endDay){
    
    $startDate = (Get-Date).AddDays(-($startDay) ) 
    $Endate = (Get-Date).AddDays(-($endDay) ) 
    Write-Host $startDay $endDay
    Write-Host $startDate $Endate
    $inactiveList = Get-ADComputer  -Filter {$_.LastLogonTimeStamp -gt $startDate -and $_.LastLogonTimeStamp -le $Endate -and $_.OperatingSystem -notlike '*server*'} | Select-Object Name, LastLogonTimeStamp, LastLogonDate,DistinguishedName

    $PSCustom_CompDetails = @()
    foreach ($comp in $inactiveList){

        $PSCustom_CompDetails += [PSCustomObject]@{
            Name = $comp.name
            DistinguishedName = $comp.DistinguishedName
        }
    }
    write-host "total" $inactiveList.count
    return $PSCustom_CompDetails
}
