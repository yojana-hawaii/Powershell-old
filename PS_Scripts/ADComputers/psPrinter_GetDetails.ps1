. "$PSScriptRoot\psSoftware_GetDetails.ps1"
# $comp = "ayush-vm"
#shared printers - similar to software list from reg
# HKEY_USER\profilename\Printers\Connections\

function fnPrinter_GetSharedPrinterRegistry($pComputer){
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

#locally installed
function fnPrinter_GetDetails($pComputer){
    $localCompName = $pComputer.Name
    # $localCompName = $pComputer
    $lComputerSMA = $pComputer.sAMAccountName


    $drivers = Get-PrinterDriver -ComputerName $localCompName -name * | Select-Object Name, Provider,IsPackageAware, `
                        @{Name="DriverVersion"; Expression={
                            $ver = $_.DriverVersion
                            $rev = $ver -band 0xffff
                            $build = ($ver -shr 16) -band 0xffff
                            $minor = ($ver -shr 32) -band 0xffff
                            $major = ($ver -shr 48) -band 0xffff
                            "$major.$minor.$build.$rev"
                        };}
    Get-WmiObject -Class win32_Printer -ComputerName $localCompName | ForEach-Object {
        $ThisPrintDriverName = $_.DriverName
        $ThisDriver = $drivers | Where-Object {  $_.Name -eq $ThisPrintDriverName }

    $localPrinter = [PSCustomObject]@{
                Name = $_.Name
                Shared = $_.Shared
                Local = $_.Local
                DriverName = $_.DriverName
                PortName = $_.PortName
                Version = $ThisDriver.DriverVersion
            }
    return $localPrinter
    }
}
# $localCompName = "ayush-vm"
# fnPrinter_GetDetails($localCompName)
