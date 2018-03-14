if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 $clusterName = "Cluster_Name"
 $advSettings =@{
     "tools.syncTime" = "FALSE"
     "time.synchronize.continue" = "FALSE"
     "time.synchronize.restore" = "FALSE"
     "time.synchronize.resume.disk" = "FALSE"
     "time.synchronize.shrink" = "FALSE"
     "time.synchronize.tools.startup" = "FALSE"
 }
 
 Connect-VIServer -Server $vCenter
 
 $vms = Get-VM -Location $clusterName
 foreach($vm in $vms) {
     $advSettings.GetEnumerator() | ForEach-Object{
         New-AdvancedSetting -Entity $vm -Name $_.Key -Value $_.Value -WhatIf -Confirm:$false -Force:$true
     }
 }
 
 Disconnect-VIServer -Confirm:$false