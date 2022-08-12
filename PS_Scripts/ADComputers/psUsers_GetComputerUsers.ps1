. "$PSScriptRoot\psStoredProcedure.ps1"


function fnUser_GetUserLoggedOnHistory($pComputer){
      $CompName = $pComputer.Name
      $CompSAMA = $pComputer.sAMAccountName
  
      $ping = Test-Connection $CompName -Quiet -Count 1
      if($ping) {
         write-host "Ping success for user"

         $users = Get-WmiObject -ClassName Win32_NetworkLoginProfile -ComputerName $CompName| Select-Object  Name,  LastLogon

         $usersObject = @()

         foreach($u in $users){
            $lastLogon = if($u.LastLogon){$u.LastLogon.substring(0, 8)}
            $lastLogon = if($u.LastLogon){([Datetime]::ParseExact($lastLogon, "yyyyMMdd", $null)) }
            write-host $u.Name $lastLogon

            $usersObject = [PSCustomObject]@{
               Name = $CompName
               sAMAccountName = $CompSAMA
               UsersLoggedIn = $u.Name
               UserLastLoginDate = $lastLogon
            }
            fnLocal_RunUsersStoredproc($usersObject)
         }
      }
}