
$date = (Get-Date).AddHours(-1)

function fnAD_GetUserDetails {  
    
    $users = Get-ADUser -Filter {whenChanged -gt $date } -Properties * |
                Select-Object  CanonicalName, sAMAccountName, GivenName, SurName, DisplayName, `
                emailAddress, DistinguishedName, StreetAddress,  `
                HomePhone, MobilePhone, OfficePhone, Fax,`
                Company, Department, Title, Description,  `
                @{Name="AccountExpires"; Expression={[datetime]::FromFileTime($_.AccountExpires)}}, `
                Enabled, 
                LastLogonDate, whenCreated,
                PasswordNeverExpires, PasswordExpired, PasswordLastSet, 
                scriptPath, LogonCount, EmployeeID,`
                @{Name="Manager"; Expression={(Get-AdUser ($_.Manager)).sAMAccountName }}

    return $users
}
function fnAD_GetGroups {
    $groups = Get-ADGroup -Filter {whenChanged -gt $date } -Properties * |
                Select-Object CanonicalName, sAMAccountName, Name, mail, DistinguishedName, Description, GroupCategory, GroupScope, whenCreated
    return $groups
}
function fnAd_GetGroupMembers {
    $groups = Get-ADGroup -Filter {whenChanged -gt $date } -Properties *  | 
                Select-Object sAMAccountName 
    $GroupMembers = @()
    foreach($grp in $groups){
        
        $groupName = $grp.sAMAccountName.ToString() 
        $GroupMembers += Get-ADGroupMember -Identity $groupName | 
                    Select-Object sAMAccountName, ObjectClass, @{name="GroupsAMAccountName"; Expression = {$groupName}; } 
    }
    return $GroupMembers
}

function fnAD_GetAllUsers_NotDelta_SqlTabledTruncated {  
    
    $users = Get-ADUser -Filter * -Properties * |
                Select-Object  CanonicalName, sAMAccountName, GivenName, SurName, DisplayName, `
                emailAddress, DistinguishedName, StreetAddress,  `
                HomePhone, MobilePhone, OfficePhone, Fax,`
                Company, Department, Title, Description,  `
                @{Name="AccountExpires"; Expression={[datetime]::FromFileTime($_.AccountExpires)}}, `
                Enabled, 
                LastLogonDate, whenCreated,
                PasswordNeverExpires, PasswordExpired, PasswordLastSet, 
                scriptPath, LogonCount, EmployeeID,`
                @{Name="Manager"; Expression={(Get-AdUser ($_.Manager)).sAMAccountName }}

    return $users
}
