

function fnLocal_StopRemotetegistryService($pComputerName){
    $serviceStatus = Get-Service -ComputerName $pComputerName -Name remoteregistry | Select-Object name, ServiceName,StartType,Status
    $service = Get-Service -ComputerName $pComputerName -Name remoteregistry 

    if ($serviceStatus.Status -eq "Running"){
        stop-service -InputObject ($service)
    }
    if ($serviceStatus.StartType -eq "Manual"){
        Set-Service -Name $serviceStatus.Name -StartupType Disabled -ComputerName $pComputerName
    }
    $serviceStatus = Get-Service -ComputerName $pComputerName -Name remoteregistry | Select-Object name, ServiceName,StartType,Status

    return $serviceStatus
}
function fnLocal_StartRemotetegistryService($pComputerName){
    $serviceStatus = Get-Service -ComputerName $pComputerName -Name remoteregistry | Select-Object name, ServiceName,StartType,Status
    $service = Get-Service -ComputerName $pComputerName -Name remoteregistry 

    if ($serviceStatus.StartType -eq "Disabled"){
        Set-Service -Name $serviceStatus.Name -StartupType Manual -ComputerName $pComputerName
    }

    if ($serviceStatus.Status -eq "Stopped"){
        start-service -InputObject ($service)
    }
    
    $serviceStatus = Get-Service -ComputerName $pComputerName -Name remoteregistry | Select-Object name, ServiceName,StartType,Status

    return $serviceStatus
}
function fnSoftware_GetLocalDetailsRegistry($pComputer){
    $ComputerName = $pComputer.Name
    $ComputerSMA = $pComputer.sAMAccountName

    $ping = Test-Connection $ComputerName -Quiet -Count 1
    if($ping) {
        write-host "software for" $ComputerName
        $CurrentServiceStatus = fnLocal_StopRemotetegistryService($ComputerName)
        write-host $ComputerName "Start Remote Registry Service" $CurrentServiceStatus.Status $CurrentServiceStatus.StartType

        $CurrentServiceStatus = fnLocal_StartRemotetegistryService($ComputerName)
        write-host $ComputerName "Update Remote Registry Service" $CurrentServiceStatus.Status $CurrentServiceStatus.StartType

        $PSCustom_CompDetails = @()
        

        if($CurrentServiceStatus.Status -eq "Running"){

            $regLocation = "Software\Microsoft\Windows\CurrentVersion\Uninstall\", 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'

            $regType = [Microsoft.Win32.RegistryHive]::LocalMachine
            $regBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($regType ,$ComputerName)
            
            foreach ($loc in $regLocation){
                if($regBase){
                    $CurrentRegKey  = $regBase.OpenSubKey($loc )
                    $ProgramKey = $CurrentRegKey.GetSubKeyNames() 

                    foreach($key in $ProgramKey){
                        $programs = $regBase.OpenSubKey($loc+$key )
                        $SoftwareName = $programs.GetValue('DisplayName')
                        if($SoftWareName -like "Service Pack*" -or $SoftWareName -like "*Update*"){
                            continue
                        }else {
                            $softwareVersion = $programs.GetValue('DisplayVersion')
                            $SoftwareVendor = $programs.GetValue('Publisher')
                            $SoftwareInstallation = $programs.GetValue('InstallDate')
                            
                            write-host $SoftwareName $softwareVersion $SoftwareVendor $SoftwareInstallation
                            $PSCustom_CompDetails += [PSCustomObject]@{
                                Name = $ComputerName
                                sAMAccountName = $ComputerSMA
                                SoftwareName = $SoftwareName 
                                softwareVersion = $softwareVersion
                                SoftwareVendor = $SoftwareVendor
                                SoftwareInstallation = $SoftwareInstallation
                            }
                        }

                    }
                }
            }
            

        }


        $CurrentServiceStatus = fnLocal_StopRemotetegistryService($ComputerName)
        write-host $ComputerName "Final emote Registry Service" $CurrentServiceStatus.Status $CurrentServiceStatus.StartType
    
    }
    return $PSCustom_CompDetails | Where-Object SoftwareName -ne $null

}

