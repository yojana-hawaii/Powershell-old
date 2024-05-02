. "$PSScriptRoot\psTest_GetDate.ps1"
. "$PSScriptRoot\psConfig.ps1"

$gDaysToKeepActive = 14d
$employeeOU = fnConfig_GetEmployeeOU
$studentOU = fnConfig_GetStudentOU
$vendorOU = fnConfig_GetVendorOU
# $baseOU = fnConfig_GetBaseOU

$itEmail = fnConfig_GetItEmail
$mailServer = fnConfig_SmtpServer
$hrEmail = fnConfig_GetHrEmail

$gNow = fnTest_GetCurrentTime


function fnLocal_PrintUser {
    [CmdletBinding()]
    param (
        $users
    )
    write-host "here in Print User"
    foreach($user in $users) {
        # $bool = $user.Created.AddDays(14) -ge $gNow
        write-host $user.GivenName $user.Surname "; Enabled:" $user.Enabled "; Last login:" $user.LastLogonDate "; Date Created" $user.Created "; Disable if no Login by" $user.Created.AddDays(14)
    }
    write-host ""
}
function fnLocal_CreateUserListForEmail {
    param ($users)

    $emailList = "`n`n`tName (Last Logon Date)`n"
    foreach ($u in $users){
        $emailList += "`t" + $u.GivenName + " " + $u.Surname + " (" + $u.LastLogonDate.ToString("yyy-MM-dd") + ")`n"
    }
    return $emailList
}
function fnLocal_CreateBody {
    param (
        $userList, $userType
    )
    $body = "Hello all, `n`nThis is an automated email." + 
        "`n`nThe following "+ $userType + " have not logged into computers system in office or remotely in the past " + 
        $gDaysToKeepActive + 
        " days. Their accounts have been disabled as of now.`n`n" + 
        "Please notify $itEmail whether the user has been " +
        "`n  a. Terminated: Futher actions required by IT team" + 
        "`n  b. Leave: IT team can activate their account when they are back." +
        $userList +
        "`n`nThank you.`nIT Team"

    return $body
}
function fnLocal_CreateSubject {
    param ($userType)
    $subject = $userType + " disabled today"
    return $subject
}
function fnLocal_EmailHR {
    [CmdletBinding()]
    param (
        $users,
        $userType
    )

    $userList = fnLocal_CreateUserListForEmail -users $users
    $body = fnLocal_CreateBody -userList $userList -userType $userType
    $subject = fnLocal_CreateSubject -userType $userType
    Send-MailMessage -From $itEmail -To $hrEmail -Cc $itEmail -Subject $subject -Body $body -SmtpServer $mailServer 

}
function fnLocal_DisableUserFromActiveDirection{
    [CmdletBinding()]
    param (
        $users,
        $userType
    ) 

    $desc_append = " (Auto deactivate on " + $gNow + ")"
    foreach($user in $users){
        $new_desc = $user.Description + $desc_append
        Disable-AdAccount -Identity $user
        Set-AdUser -Identity $user -Description $new_desc
    }

    fnLocal_EmailHR -users $users -userType $userType
}
function fnLocal_ExcludeNewUserAccounts {
    [CmdletBinding()]
    param (
        $users,
        $userType
    )

    $users = $users | Where-Object { ($null -ne $_.LastLogonDate) -and ($_.Created.AddDays(14) -lt $gNow  ) }
    
    if ($users.count -le 0 ){
        write-host $userType "dormant but those accounts created last 14 days"
        return ""
    }
    fnLocal_PrintUser -users $users
    fnLocal_DisableUserFromActiveDirection  -users $users -userType $userType
}
function fnLocal_GetAdditionalADUserDetails {
    [CmdletBinding()]
    param (
        $users,
        $userType
    )    
    $totalUsers = $users.count
    write-host "dormant - " $totalUsers
    if (0 -eq $totalUsers -or $null -eq $totalUsers){
        write-host $userType "- no dormant period."
        return ""
    }
    $users = $users | Get-ADUser -Identity { $_ } -Properties *
    fnLocal_PrintUser $users
    fnLocal_ExcludeNewUserAccounts -users $users -userType $userType

    write-host "X"
    return
}

function fnLocal_FindDormantUsers {
    [CmdletBinding()]
    param (
        $userType,
        $ou
    )


    # # Find all users inactive in $days and not disabled
    $dormantUsers  = Search-ADAccount -AccountInactive -TimeSpan( [timespan] $gDaysToKeepActive )  -UsersOnly -SearchBase $ou | 
        Where-Object { $_.Enabled } |
        Sort-Object -Property LastLogon -Descending

    fnLocal_GetAdditionalADUserDetails -users $dormantUsers -userType $userType
}

function fnDisableDormantUser {
    write-host "Start Employees"
    fnLocal_FindDormantUsers -ou $employeeOU -userType "Employees"
    write-host "Start Students"
    fnLocal_FindDormantUsers -ou $studentOU -userType "Students"
    write-host "Start Vendors"
    fnLocal_FindDormantUsers -ou $vendorOU -userType "Vendors"


    #### fnLocal_FindDormantUsers -ou $baseOU -userType "All Users"
}
