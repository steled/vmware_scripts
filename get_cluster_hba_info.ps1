if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
   ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

$vCenter = "vCenter"
$vmClusterName = "Cluster"

Connect-VIServer -Server $vCenter

Get-Cluster $vmClusterName | Get-VMHost | Get-VMHostHba -Type FibreChannel | Select VMHost,Device,@{N="Node WWN";E={"{0:X}" -f $_.NodeWorldWideName}},@{N="Port WWN";E={"{0:X}" -f $_.PortWorldWideName}} | sort VMHost,Device

Disconnect-VIServer -Confirm:$false
