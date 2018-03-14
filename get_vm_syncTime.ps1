if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 $clusterName = "Cluster_Name"
 
 Connect-VIServer -Server $vCenter
 
 Get-VM -Location $clusterName | Select Name,@{N='TimeSync';E={$_.ExtensionData.Config.Tools.syncTimeWithHost}} | ft
 
 Disconnect-VIServer -Confirm:$false