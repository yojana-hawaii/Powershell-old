. "$PSScriptRoot\psFileConfig.ps1"

$hl7FileLocation = fnConfig_FileLocation

function fnFileMgmt_FileByYearMonthDay {

    $fileType = $hl7FileLocation + "*.hl7"
    

    
    Get-ChildItem $fileType | Foreach-Object {
        $lastChangeDate = $_.LastWriteTime.ToShortDateString()
        $fileYear = Get-Date $LastChangeDate -Format yyyy
        $fileMonth = Get-Date $LastChangeDate -Format MM
        $fileDate = Get-Date $LastChangeDate -Format yyyy.MM.dd

        $destination = $hl7FileLocation + $fileYear + "\" + $fileYear + "." + $fileMonth + "\" + $fileDate

        write-host $destination

        if( -not (Test-Path $destination)){
            New-Item -ItemType Directory -Path $destination
        } else {
            Write-Host "ignore"
        }
        Move-Item $_.Fullname $destination
        # Move-Item $_.Name $destination
        Write-Host $destination
        
    }

}

function fnFileMgmt_ZipOldFolder{
    $today_year = Get-Date -Format yyyy 
    $today_month = Get-Date -Format MM
    $monthsToWaitBeforeArchiveAndDelete = 2

    Get-ChildItem -Directory -Path $hl7FileLocation | ForEach-Object {
        write-host $_.Name $today_year
        if($_.Name -as [int] -lt $today_year -as [int]){
            if($today_month -as [int] -gt $monthsToWaitBeforeArchiveAndDelete ){
                write-host "ready for zip" $_.FullName
                $zipFileNam = $_.FullName + ".zip"
                Compress-Archive -Path $_.FullName -DestinationPath  $zipFileNam
            }
            else {"month not ready"}
        }
        else {"year not ready"}
    }

    

}

# fnFileMgmt_ZipOldFolder