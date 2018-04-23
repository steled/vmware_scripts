if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 $vHost = "vHost"
 $clusterName = "Cluster"
 
 Connect-VIServer -Server $vCenter
 
 Get-VM -Location $clustername | where {($_ | Get-VirtualPortGroup)} | Select Name,@{N="VLAN";E={[string]::Join('#',(Get-VirtualPortGroup -VM $_ | %{$_.VLanID}))}} | Sort-Object -Property VLAN | ft
 
 Disconnect-VIServer -Confirm:$false