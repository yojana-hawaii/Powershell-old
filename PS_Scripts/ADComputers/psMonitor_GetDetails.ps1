. "$PSScriptRoot\psStoredProcedure.ps1"

function fnMonitor_GetMonitorDetails($pComputer){
    $CompName = $pComputer.Name
    $CompSAMA = $pComputer.sAMAccountName

    $ping = Test-Connection $CompName -Quiet -Count 1
    if($ping) {
        write-host "Ping success"

        $monitors = Get-WmiObject WmiMonitorId -namespace root\wmi -ComputerName $CompName | Select-Object ManufacturerName,UserFriendlyName,SerialNumberID, YearOfManufacture
        $videos = Get-WmiObject -Class Win32_VideoController -ComputerName $CompName | Select-Object deviceid, caption, VideoModeDescription
        $localMonitor = @() 
        $localVideo = @()
        $monitorDetails = @()

        $counter = 1
        foreach($monitor in $monitors){
            $localMonitor += [PSCustomObject]@{
                Name = $CompName
                sAMAccountName = $CompSAMA
                MonitorManufacturer = Decode-Ascii($monitor.ManufacturerName -notmatch 0)
                MonitorName = Decode-Ascii($monitor.UserFriendlyName -notmatch 0)
                MonitorSerial = Decode-Ascii($monitor.SerialNumberID -notmatch 0)
                MonitorYear = $monitor.YearOfManufacture
                Counter = $counter
            }
            $counter += 1
        }

        $counter = 1
        foreach($video in $videos){
            $localVideo += [PSCustomObject]@{
                Name = $CompName
                sAMAccountName = $CompSAMA
                DeviceID = $video.deviceid
                MonitorCaption = $video.caption
                MonitorResolution = $video.VideoModeDescription
                Counter = $counter
            }
            $counter += 1
        }

        $localMonitor | ForEach-Object {
            $currentCount = $_.Counter
            $currentVideo = $localVideo | Where-Object {$_.Counter -eq $currentCount}
            
            $monitorDetails = [PSCustomObject]@{
                Name = $_.Name
                sAMAccountName = $_.sAMAccountName
                MonitorManufacturer = $_.MonitorManufacturer
                MonitorName = $_.MonitorName
                MonitorSerial = $_.MonitorSerial
                MonitorYear = $_.MonitorYear
                MonitorCaption = $currentVideo.MonitorCaption
                MonitorResolution = $currentVideo.MonitorResolution
            }
            fnSp_InsertMonitorDetails($monitorDetails)
        }
    }
}




