function fnConfig_GetPrimaryDC{
    return "dc1.example.com"   
}

function fnConfig_GetDomain{
    return "example.com"
}

function fnConfig_GetSqlConnectionString{
    return "Server='server name';Integrated Security=True;Initial Catalog='ADWarehouse';"
}

function fnConfig_GetInactive14DaysOU{
    return "OU=014Plus,OU=Disabled Computer,DC=example,DC=com"
}

function fnConfig_GetInactive30DaysOU{
    return "OU=030Plus,OU=Disabled Computer,DC=example,DC=com"
}

function fnConfig_GetInactive90DaysOU{
    return "OU=090Plus,OU=Disabled Computer,DC=example,DC=com"
}
function fnConfig_GetInactive180DaysOU{
    return "OU=180Plus,OU=Disabled Computer,DC=example,DC=com"
}
function fnConfig_GetInactive365PlusOU{
    return "OU=365Plus,OU=Disabled Computer,DC=example,DC=com"
}
function fnConfig_GetInactiveServerOU{
    return "OU=DisabledServers,OU=Disabled Computer,DC=example,DC=com"
}
function fnConfig_GetDisabledComputerOU{
    return "OU=Disabled Computer,DC=exampple,DC=com"
}
function fnConfig_GetOutofNetworkOU{
    return "*OU=Out Of Network,DC=example,DC=com"
}
function fnConfig_GetRemoteOU{
    return "*OU=Remote,DC=example,DC=com"
}
function fnConfig_GetThinClientOU{
    return "OU=Thin Client,DC=example,DC=com"
}

function fnConfig_GetWorkstationOU{
    return "OU=Workstations_OU1,DC=example,DC=com", "OU=Workstations_OU1,DC=example,DC=com", "OU=Disabled Computer,DC=example,DC=com"
}

function fnConfig_s3FileLocation{
    $s3FileLocation = "\\Location\PS_Scripts\ADComputers\HP_ScanApp\s3\ScanApp.ini"
    return $s3FileLocation
 }
 function fnConfig_s4FileLocation{
    $s4_fileLocation = "\\Location\PS_Scripts\ADComputers\HP_ScanApp\s4\ScanApp.ini"
    return $s4_fileLocation
 }