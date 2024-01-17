
. "$PSScriptRoot\psConfig.ps1"

$file = fnConfig_MissingSlipFile
$data = Import-Excel $file
$data.GetType()
