
. "$PSScriptRoot\psConfig.ps1"
. "$PSScriptRoot\psStoredProcedure.ps1"

$SMTP = fnConfig_SmtpServer
$FROM = fnConfig_MissingSlipEmailFrom
$med_CC = fnConfig_MissingSlipEmailCC
$BH_CC = fnConfig_MissingSlipEmailCCBH
$me = fnConfig_MyEmail


function fnMissingSlip_FindEmail($name){
    $prov = $name.split(',')
    $last = $prov[0].trim()
    $first = $prov[1].trim()
    $email = ""

    $directoryList = fnSp_GetProviders
    foreach($provider in $directoryList){
        if($provider.FirstName -eq $first){
            if($provider.LastName -eq $last){
                $email = $provider.Email
                $bh = $provider.BH
                break
            }
        }
    }

    if ($name -eq "Sato, Darrin"){
        $email = "dsato@kphc.org"
        $bh = 1
    }

    if ($name -eq "Yamamoto-Kubo, Tracey"){
        $email = "tyamamoto@kphc.org"
        $bh = 0
    }

    return @($email, $bh)
}

function fnMissingSlip_ProviderEmailMissing($Provider){
    Send-MailMessage -smtpserver $SMTP -from $me -to $me -subject "Provider email for missing slip" -body "Need to hard code provider email in psMissingSlip.ps1 since email not standard first initial lastname"
}
function fnMissingSlip_OrganizeInTable($data){
    
    $HtmlTable = "
    <table border='1' aligh='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,calibri,helvetica,sans-serif;text-align:left;'> 
        <tr style='font-size:13px;font-weight=normal;background:#FFFFFF'>
            <th align=left><b>Patient Name</b></th>
            <th align=left><b>Patient ID</b></th>
            <th align=left><b>Date of Service</b></th>
        </tr>
    "

    foreach($row in $data){
        $HtmlTable += "<tr style='font-size:12px;font-weight=normal;background:#FFFFFF'>
            <td>" + $row."Patient Name" + "</td>
            <td>" + $row."Patient ID" + "</td>
            <td>" + $row."Date Of Service" + "</td>
        </tr>
        "
    }

    $HtmlTable += "</table>"

    return $HtmlTable
}
function fnMissingSlip_PerProvider($prov){
    $encounterCount = $prov.Count
    $ProviderName = $prov.Name
    $provList = $prov.Group

    $temp = fnMissingSlip_FindEmail -name $ProviderName
    $email = $temp[0]
    $bh = $temp[1]

    if($bh -eq 1){
        $CC = $BH_CC + " " + $med_CC + " " + $FROM
    }
    else {
        $CC = $med_CC + " " + $FROM
    }

    if($provider.email -eq '') {fnMissingSlip_ProviderEmailMissing -provider $ProviderName}

    $oldest = $provList | Sort-Object -Property "Date Of Service" | Select-Object -ExpandProperty "Date Of Service" -First 1
    $newest = $provList | Sort-Object -Property "Date Of Service" | Select-Object -ExpandProperty "Date Of Service" -Last 1

    $htmltable = fnMissingSlip_OrganizeInTable -data $provList

    $SUBJECT = $ProviderName + " - " + $encounterCount + " open encounters"
    $BODY = "
        <br><br>
    Hello, This is an automated email. $encounterCount visits between $oldest and $newest are incomplete, missing e&m code or diagnosis. Thank you.
    <br><br>
    " + $htmltable
     write-host $subject
     write-host $body 
    
    Send-MailMessage -smtpserver $SMTP -from $FROM -to $email -cc $CC -subject $SUBJECT -body $BODY -bodyashtml
}


function fnMissingSlip_Main{

    $file = fnConfig_MissingSlipFile
    $fileDate = (Get-Item $file).LastWriteTime
    $fileCreatedInLast24Hours = $fileDate -gt (Get-Date).AddDays(-1)
    if ($fileCreatedInLast24Hours){
        $data = Import-Excel $file
        $groupByProvider = $data | Group-Object Provider 

        foreach($prov in $groupByProvider){
            fnMissingSlip_PerProvider -prov $prov
            
        }
    } else {
        write-host "Ignore older files"
        return 
    }
}
fnMissingSlip_Main