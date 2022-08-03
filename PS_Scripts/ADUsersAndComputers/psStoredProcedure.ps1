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

function fnSp_InsertAdComputers($pADDetails){
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



        $cmd.Parameters[0].Value = fnLocal_GetStringFromObject($pADDetails.Name)
        $cmd.Parameters[1].Value = fnLocal_GetStringFromObject($pADDetails.DistinguishedName)
        $cmd.Parameters[2].Value = fnLocal_GetStringFromObject($pADDetails.Created)
        $cmd.Parameters[3].Value = fnLocal_GetStringFromObject($pADDetails.Modified)
        $cmd.Parameters[4].Value = fnLocal_GetStringFromObject($pADDetails.UserAccountControl)
        $cmd.Parameters[5].Value = fnLocal_GetStringFromObject($pADDetails.OSVersion)
        $cmd.Parameters[6].Value = fnLocal_GetStringFromObject($pADDetails.IPV4Address)
        $cmd.Parameters[7].Value = fnLocal_GetStringFromObject($pADDetails.LastLogonDate)
        $cmd.Parameters[8].Value = fnLocal_GetStringFromObject($pADDetails.LogonCount)
        $cmd.Parameters[9].Value = fnLocal_GetStringFromObject($pADDetails.Description)
        $cmd.Parameters[10].Value = fnLocal_GetStringFromObject($pADDetails.OU)
        $cmd.Parameters[11].Value = fnLocal_GetStringFromObject($pADDetails.Active)
        $cmd.Parameters[12].Value = fnLocal_GetStringFromObject($pADDetails.Server)
        $cmd.Parameters[13].Value = fnLocal_GetStringFromObject($pADDetails.Thin_Client)
        $cmd.Parameters[14].Value = fnLocal_GetStringFromObject($pADDetails.BitLockerPasswordDate)
        $cmd.Parameters[15].Value = fnLocal_GetStringFromObject($pADDetails.OperatingSystem)
        $cmd.Parameters[16].Value = fnLocal_GetStringFromObject($pADDetails.OperatingSystemVersion)
        $cmd.Parameters[17].Value = fnLocal_GetStringFromObject($pADDetails.sAMAccountName)



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
function fnSp_CleanUpHardwareDetails{
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $ConnString = fnConfig_GetSqlConnectionString
    $conn.ConnectionString =  $ConnString
    
    try{
        $conn.Open()
        $cmd = $conn.CreateCommand()
        write-host "Connection:" $conn.State
        $cmd.CommandType = 'StoredProcedure'
        $cmd.CommandText = "dbo.spCleanUp_psHardwareDetails"


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

function fnSp_InsertHardwareDetails($pHardwareDetails){
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $ConnString = fnLocal_GetSqlConnectionString
    $conn.ConnectionString =  $ConnString
    
    try{
        $conn.Open()
        $cmd = $conn.CreateCommand()
        # write-host "Connection:" $conn.State
        $cmd.CommandType = 'StoredProcedure'
        $cmd.CommandText = "dbo.spInsert_psLocalComputers"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sAMAccountName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Name", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SerialNumber", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Last_Security_KB", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Last_SecurityPatch_date", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Print_Status", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Kace_Status", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Sentinel_Status", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Sysaid_Status", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DellEncryption_Status", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Cylance_Status", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Offline", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Print_SpoolSv_date", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Print_LocalSpl_date", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Print_Win32Spl_date", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
       
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Manufacturer", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Model", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@RAM_GB", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@VM", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Processor", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@BiosVersion", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IsLaptop", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastReboot", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@CurrentUser", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@WakeUpType", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@EncryptionLevel", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@NumberOfUsers", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OSArchitecture", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DiskModel", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DiskSizeGB", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DiskType", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@TpmEnabled", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@TpmVersion", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@BiosReleaseDate", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastPatchKb", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@LastPatchDate", [System.Data.SqlDbType]::Varchar, 50)))|Out-Null
        
        $cmd.Parameters[0].Value = fnLocal_GetStringFromObject($pHardwareDetails.sAMAccountName)
        $cmd.Parameters[1].Value = fnLocal_GetStringFromObject($pHardwareDetails.Name)
        $cmd.Parameters[2].Value = fnLocal_GetStringFromObject($pHardwareDetails.SerialNumber)
        $cmd.Parameters[3].Value = fnLocal_GetStringFromObject($pHardwareDetails.Last_Security_KB)
        $cmd.Parameters[4].Value = fnLocal_GetStringFromObject($pHardwareDetails.Last_SecurityPatch_date)
        $cmd.Parameters[5].Value = fnLocal_GetStringFromObject($pHardwareDetails.Print_Status)
        $cmd.Parameters[6].Value = fnLocal_GetStringFromObject($pHardwareDetails.Kace_Status)
        $cmd.Parameters[7].Value = fnLocal_GetStringFromObject($pHardwareDetails.Sentinel_Status)
        $cmd.Parameters[8].Value = fnLocal_GetStringFromObject($pHardwareDetails.Sysaid_Status)
        $cmd.Parameters[9].Value = fnLocal_GetStringFromObject($pHardwareDetails.DellEncryption_Status)
        $cmd.Parameters[10].Value = fnLocal_GetStringFromObject($pHardwareDetails.Cylance_Status)
        $cmd.Parameters[11].Value = fnLocal_GetStringFromObject($pHardwareDetails.Offline)
        $cmd.Parameters[12].Value = fnLocal_GetStringFromObject($pHardwareDetails.SpoolSv_Date)
        $cmd.Parameters[13].Value = fnLocal_GetStringFromObject($pHardwareDetails.LocalSpl_Date)
        $cmd.Parameters[14].Value = fnLocal_GetStringFromObject($pHardwareDetails.Win32Spl_Date)

        $cmd.Parameters[15].Value = fnLocal_GetStringFromObject($pHardwareDetails.Manufacturer)
        $cmd.Parameters[16].Value = fnLocal_GetStringFromObject($pHardwareDetails.Model)
        $cmd.Parameters[17].Value = fnLocal_GetStringFromObject($pHardwareDetails.RAM_GB)
        $cmd.Parameters[18].Value = fnLocal_GetStringFromObject($pHardwareDetails.VM)
        $cmd.Parameters[19].Value = fnLocal_GetStringFromObject($pHardwareDetails.Processor)
        $cmd.Parameters[20].Value = fnLocal_GetStringFromObject($pHardwareDetails.BiosVersion)
        $cmd.Parameters[21].Value = fnLocal_GetStringFromObject($pHardwareDetails.IsLaptop)

        $cmd.Parameters[22].Value = fnLocal_GetStringFromObject($pHardwareDetails.LastReboot)
        $cmd.Parameters[23].Value = fnLocal_GetStringFromObject($pHardwareDetails.CurrentUser)
        $cmd.Parameters[24].Value = fnLocal_GetStringFromObject($pHardwareDetails.WakeUpType)
        $cmd.Parameters[25].Value = fnLocal_GetStringFromObject($pHardwareDetails.EncryptionLevel)
        $cmd.Parameters[26].Value = fnLocal_GetStringFromObject($pHardwareDetails.NumberOfUsers)
        $cmd.Parameters[27].Value = fnLocal_GetStringFromObject($pHardwareDetails.OSArchitecture)
        $cmd.Parameters[28].Value = fnLocal_GetStringFromObject($pHardwareDetails.Disk_Model)
        $cmd.Parameters[29].Value = fnLocal_GetStringFromObject($pHardwareDetails.Disk_Size_GB)
        $cmd.Parameters[30].Value = fnLocal_GetStringFromObject($pHardwareDetails.Disk_Type)

        $cmd.Parameters[31].Value = fnLocal_GetStringFromObject($pHardwareDetails.TpmEnabled)
        $cmd.Parameters[32].Value = fnLocal_GetStringFromObject($pHardwareDetails.TpmVersion)
        $cmd.Parameters[33].Value = fnLocal_GetStringFromObject($pHardwareDetails.BiosReleaseDate)
    
        $cmd.Parameters[34].Value = fnLocal_GetStringFromObject($pHardwareDetails.LastPatchKb)
        $cmd.Parameters[35].Value = fnLocal_GetStringFromObject($pHardwareDetails.LastPatchDate)

         
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
    write-host "Computer Details updated. SQL Connection Status: " $conn.State
    return $sqlResult
}

function fnSp_InsertSoftwareProc($pSoftwareDetails){
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $ConnString = fnLocal_GetSqlConnectionString
    $conn.ConnectionString =  $ConnString

    
    try{
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandType = 'StoredProcedure'
        $cmd.CommandText = "dbo.spInsert_psLocalSoftwares"

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Name", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sAMAccountName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null

        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareName", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareVersion", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareVendor", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null
        $cmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SoftwareInstallation", [System.Data.SqlDbType]::Varchar, 100)))|Out-Null


        $cmd.Parameters[0].Value = fnLocal_GetStringFromObject($pSoftwareDetails.Name)
        $cmd.Parameters[1].Value = fnLocal_GetStringFromObject($pSoftwareDetails.sAMAccountName)

        $cmd.Parameters[2].Value = fnLocal_GetStringFromObject($pSoftwareDetails.SoftwareName)
        $cmd.Parameters[3].Value = fnLocal_GetStringFromObject($pSoftwareDetails.SoftwareVersion)
        $cmd.Parameters[4].Value = fnLocal_GetStringFromObject($pSoftwareDetails.SoftwareVendor)
        $cmd.Parameters[5].Value = fnLocal_GetStringFromObject($pSoftwareDetails.SoftwareInstallation)

        
        $cmd.CommandTimeout = 0
        $rtn = $cmd.ExecuteNonQuery()
        
        $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $sqlAdapter.SelectCommand = $cmd
        $DataSet =  New-Object System.Data.DataSet
        $rtn = $sqlAdapter.Fill($DataSet)
        $sqlResult = $DataSet.Tables[0]   
    }catch{
        write-host "failed"
        Write-Host $Error[0].Exception.Message
    }finally{
        $conn.Dispose()
        $cmd.Dispose()
        $conn.Close()
    }   
    return $sqlResult

}

function fnSp_GetRandomComputersUsingStoredProc{
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $ConnString = fnLocal_GetSqlConnectionString
    $conn.ConnectionString =  $ConnString
    
    
    try{
        $conn.Open()
        $cmd = $conn.CreateCommand()
        write-host "Connection:" $conn.State
        $cmd.CommandType = 'StoredProcedure'

        $cmd.CommandText = "dbo.spGet_psRandomComputerToScan"

        $cmd.CommandTimeout = 0
        $result = $cmd.ExecuteReader()
        
        $data = New-Object System.Data.DataTable
        $data.Load($result)


    }catch{
        write-host "failed"
        Write-Host $Error[0].Exception.Message
    }finally{
        $conn.Dispose()
        $cmd.Dispose()
        $conn.Close()
    }   
    write-host "Connection:", $conn.State
    return $data

}
