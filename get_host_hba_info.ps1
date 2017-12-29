if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
   ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

$vCenter = "vCenter"
$vmHostName = "Hostname"

Connect-VIServer -Server $vCenter

Get-VMHost $vmHostName | Get-VMHostHba -Type FibreChannel | Select VMHost,Device,@{N="Node WWN";E={"{0:X}" -f $_.NodeWorldWideName}},@{N="Port WWN";E={"{0:X}" -f $_.PortWorldWideName}}

Disconnect-VIServer -Confirm:$false
