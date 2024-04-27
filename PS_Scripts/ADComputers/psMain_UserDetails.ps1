
. "$PSScriptRoot\psAD_GetUsersAndGroups.ps1"
. "$PSScriptRoot\psTest_GetDate.ps1"
. "$PSScriptRoot\psStoredProcedure.ps1"



$gStart_time = fnTest_GetCurrentTime


$adUsers = fnAD_GetAllUsers_NotDelta_SqlTabledTruncated
foreach($user in $adUsers){
    fnSp_InsertAdUsers($user)
}
    

$adgroups = fnAD_GetGroups
foreach($grp in $adgroups){
    # $grp
    fnSp_InsertAdGroups($grp)
}

$adGroupMembers = fnAd_GetGroupMembers
foreach($member in $adGroupMembers){
    # $member
    fnSp_InsertAdGroupMembers($member)
}

$deltaChangeUser = fnAD_GetUserDetails_Delta
foreach($user in $deltaChangeUser){
    fnSp_InsertAdUsers($user)
}




$gEnd_time = fnTest_GetCurrentTime
$gDuration = $gEnd_time - $gStart_time
Write-Host "Start: " $gStart_time ", End: " $gEnd_time ", Total time: " $gDuration.TotalMinutes
