. "$PSScriptRoot\psStoredProcedure.ps1"
. "$PSScriptRoot\psConfig.ps1"

$MODIFIED_S3_FILE = fnConfig_s3FileLocation
$MODIFIED_S4_FILE = fnConfig_s4FileLocation
$SCANNER_PROFILE_NAME = "ATHENA_SCAN"
$DEFAULT_USERNAME = "newUser"

function fnLocal_CreateFoldersIfNotExists($folderPath) {
    if (-Not(Test-Path $folderPath)){
        New-Item -ItemType Directory -Force $folderPath
    }
    return
}
function fnLocal_CopyModifiedDefaultFileIfNotExists($srcIniFile, $dstIniFile, $dstIniFilePath){
    if(-not(Test-Path -path $dstIniFile)){
        Copy-Item -Path $srcIniFile -Destination $dstIniFilePath
    }
    return
}
function fnLocal_CheckNecessaryStringExistsInFile($iniFile, $str){
    $retStr = Select-String -Pattern $str -Path $iniFile
    return $null -ne $retStr
}
function fnLocal_DeleteIniFile($srcIniFile, $dstIniFile, $dstIniFilePath){
    Remove-Item -Path $dstIniFile -Recurse
    fnLocal_CopyModifiedDefaultFileIfNotExists -dstIniFilePath $dstIniFilePath -srcIniFile $srcIniFile -dstIniFile $dstIniFileWithPath
}
function fnLocal_CheckFileContent($dstIniFilePath, $srcIniFile, $username){
    $dstIniFileWithPath = $dstIniFilePath+"ScanApp.ini"

    fnLocal_CopyModifiedDefaultFileIfNotExists -dstIniFilePath $dstIniFilePath -srcIniFile $srcIniFile -dstIniFile $dstIniFileWithPath

    $scannerProfileExists = fnLocal_CheckNecessaryStringExistsInFile -iniFile $dstIniFileWithPath -str $SCANNER_PROFILE_NAME

    
    if(-not $scannerProfileExists){
        fnLocal_DeleteIniFile -dstIniFilePath $dstIniFilePath -srcIniFile $srcIniFile -dstIniFile $dstIniFileWithPath
    }

    $defaultUsernameExists = fnLocal_CheckNecessaryStringExistsInFile -iniFile $dstIniFileWithPath -str $DEFAULT_USERNAME
    if($defaultUsernameExists){
        (Get-Content -Path $dstIniFileWithPath) -replace($DEFAULT_USERNAME, $username) | Set-Content -Path $dstIniFileWithPath
    }
    
}

function fnLocal_Main($compName){
    $prefix = '\\' + $compName + '\c$\users\'
    $suffix = '\AppData\Local\HP'
    $suffix2 = '\HP Scan'
    $suffix_s3 = '\HP ScanJet Pro 3000 s3\'
    $suffix_s4 = '\HP ScanJet Pro 3000 s4\'

    if (Test-Path -Path $prefix){
        $usernamesInTheComputer = Get-ChildItem($prefix)
        
        foreach($user in $usernamesInTheComputer){
            if([string]$user -eq '01' -or [string]$user -eq 'admin'  -or [string]$user -eq 'public'){
                continue
            } else {
                $s3_path = $prefix + $user + $suffix + $suffix2 + $suffix_s3
                $s3_path2 = $prefix + $user + $suffix + $suffix_s3
                $s4_path = $prefix + $user + $suffix + $suffix2 + $suffix_s4

                try {
                    fnLocal_CreateFoldersIfNotExists -folderPath $s3_path
                    fnLocal_CreateFoldersIfNotExists -folderPath $s3_path2
                    fnLocal_CreateFoldersIfNotExists -folderPath $s4_path
                    write-host ""
                    fnLocal_CheckFileContent -dstIniFilePath $s3_path -srcIniFile $MODIFIED_S3_FILE -username $user 
                    fnLocal_CheckFileContent -dstIniFilePath $s3_path2 -srcIniFile $MODIFIED_S3_FILE -username $user
                    fnLocal_CheckFileContent -dstIniFilePath $s4_path -srcIniFile $MODIFIED_S4_FILE -username $user
                    Write-Host "Computer:" $compName " User:" $user " complete."
                }
                catch {
                    Write-Host "Computer:" $compName " User:" $user " failed."
                }

            }
        }
    }
    else {
        write-host $prefix + " not accessible."
    }
    # break
}

function fnHp_UpdateScannerProfile{
    $ComputersWithhpDrivers = fnSp_GetComputersWithHpDrivers

    foreach($computer in $ComputersWithhpDrivers ){
        # \\%COMPUTERNAME%\c$\users\USERNAME%\AppData\Local\Hp\%VERSION%\ScanApp.ini
        $computerName = [string]$computer.Name
        fnLocal_Main -compName $computerName
    }
}




# fnHp_UpdateScannerProfile

fnLocal_Main -compName "710-2FD01-22"