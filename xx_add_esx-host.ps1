if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
   ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

$vCenter = "vCenter"

Connect-VIServer -Server $vCenter

Get-Content xx_hosts.txt | Foreach-Object { Add-VMHost $_ -Location (Get-Cluster Cluster) -User root -Password hpinvent -RunAsync -force:$true}

Disconnect-VIServer -Confirm:$false
