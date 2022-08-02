. "$PSScriptRoot\psConfig.ps1"

function fnLocal_GetStringFromObject($pObjParam){
    if ([string]::IsNullOrEmpty($pObjParam))
    {
        return ""
    }
    else 
    {
        return $pObjParam.ToString();
    }
}

function fnSp_InsertAdComputers($pComputer){
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $ConnString = fnConfig_GetSqlConnectionString
    $conn.ConnectionString =  $ConnString
    
    try{
        $conn.Open()
        $cmd = $conn.CreateCommand()
        write-host "Connection:" $conn.State
        $cmd.CommandType = 'StoredProcedure'
        $cmd.CommandText = "dbo.spInsert_psADComputers"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Name", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DistinguishedName", [System.Data.SqlDbType]::Varchar, 500)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Created", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Modified", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@UserAccountControl", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OSVersion", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IPV4Address", [System.Data.SqlDbType]::Varchar, 30)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastLogonDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LogonCount", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Description", [System.Data.SqlDbType]::Varchar, 500)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OU", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Active", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Server", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Thin_Client", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@BitLockerPasswordDate", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OperatingSystem", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OperatingSystemVersion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sAMAccountName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null



        $cmd.Parameters[0].Value = fnLocal_GetStringFromObject($pComputer.Name)
        $cmd.Parameters[1].Value = fnLocal_GetStringFromObject($pComputer.DistinguishedName)
        $cmd.Parameters[2].Value = fnLocal_GetStringFromObject($pComputer.Created)
        $cmd.Parameters[3].Value = fnLocal_GetStringFromObject($pComputer.Modified)
        $cmd.Parameters[4].Value = fnLocal_GetStringFromObject($pComputer.UserAccountControl)
        $cmd.Parameters[5].Value = fnLocal_GetStringFromObject($pComputer.OSVersion)
        $cmd.Parameters[6].Value = fnLocal_GetStringFromObject($pComputer.IPV4Address)
        $cmd.Parameters[7].Value = fnLocal_GetStringFromObject($pComputer.LastLogonDate)
        $cmd.Parameters[8].Value = fnLocal_GetStringFromObject($pComputer.LogonCount)
        $cmd.Parameters[9].Value = fnLocal_GetStringFromObject($pComputer.Description)
        $cmd.Parameters[10].Value = fnLocal_GetStringFromObject($pComputer.OU)
        $cmd.Parameters[11].Value = fnLocal_GetStringFromObject($pComputer.Active)
        $cmd.Parameters[12].Value = fnLocal_GetStringFromObject($pComputer.Server)
        $cmd.Parameters[13].Value = fnLocal_GetStringFromObject($pComputer.Thin_Client)
        $cmd.Parameters[14].Value = fnLocal_GetStringFromObject($pComputer.BitLockerPasswordDate)
        $cmd.Parameters[15].Value = fnLocal_GetStringFromObject($pComputer.OperatingSystem)
        $cmd.Parameters[16].Value = fnLocal_GetStringFromObject($pComputer.OperatingSystemVersion)
        $cmd.Parameters[17].Value = fnLocal_GetStringFromObject($pComputer.sAMAccountName)



        $cmd.CommandTimeout = 0
        $cmd.ExecuteNonQuery()
        
        $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $sqlAdapter.SelectCommand = $cmd
        $DataSet =  New-Object System.Data.DataSet
        $sqlAdapter.Fill($DataSet)
        $sqlResult = $DataSet.Tables[0]   
    }catch{
        write-host "failed"
        Write-Host $Error[0].Exception.Message
    }finally{
        $conn.Dispose()
        $cmd.Dispose()
        $conn.Close()
    }   
    write-host "Connection:", $conn.State
    return $sqlResult
}

function fnSp_CleanUpAdComputers{
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $ConnString = fnConfig_GetSqlConnectionString
    $conn.ConnectionString =  $ConnString
    
    try{
        $conn.Open()
        $cmd = $conn.CreateCommand()
        write-host "Connection:" $conn.State
        $cmd.CommandType = 'StoredProcedure'
        $cmd.CommandText = "dbo.spCleanUp_psADComputer"


        $cmd.CommandTimeout = 0
        $cmd.ExecuteNonQuery()
        
        $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $sqlAdapter.SelectCommand = $cmd
        $DataSet =  New-Object System.Data.DataSet
        $sqlAdapter.Fill($DataSet)
        $sqlResult = $DataSet.Tables[0]   
    }catch{
        write-host "failed"
        Write-Host $Error[0].Exception.Message
    }finally{
        $conn.Dispose()
        $cmd.Dispose()
        $conn.Close()
    }   
    write-host "Connection:", $conn.State
    return $sqlResult
}
