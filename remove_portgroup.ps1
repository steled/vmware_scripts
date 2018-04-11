if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 $vHost = "vHost"
 $vSwitch = "vSwitch"
 
 Connect-VIServer -Server $vCenter
 
 $vPortGroup = Get-VirtualPortGroup -VMHost $vHost -VirtualSwitch $vSwitch -Name "cust*"
 Remove-VirtualPortGroup -VirtualPortGroup $vPortGroup -Confirm:$false
 
 Disconnect-VIServer -Confirm:$false