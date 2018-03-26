if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 
 Connect-VIServer -Server $vCenter
 
 Get-VMHost -Location (Get-Cluster "Cluster") | Get-VM | Select Name, @{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))}}
 
 Disconnect-VIServer -Confirm:$false