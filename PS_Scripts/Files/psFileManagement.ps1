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

