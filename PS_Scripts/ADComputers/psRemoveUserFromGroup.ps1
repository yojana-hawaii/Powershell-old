
$groupName = 'fw_openall'
$members = Get-ADGroupMember -Identity $groupName

function fnRemoveUsersFromGroup{
    
    foreach ($member in $members){
        Remove-ADGroupMember -Identity $groupName -Members $member -Confirm:$False
        write-host "insude"
    }
    
}

fnRemoveUsersFromGroup