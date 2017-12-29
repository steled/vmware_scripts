if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
   ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

$vCenter = "vCenter"
$sourceHost = "Source_Hostname"
$destHost = "Destination_Hostname"

#Connect to vCenter
if (!($viServer = Connect-VIServer –Server $vCenter -Credential (Get-Credential -message "vCenter Login for $vCenter"))){
	Write-Warning "Unable to connect to VIServer. Script will be aborted.";  
	Write-warning $error[0].Exception.Message;
	return
}

$VMs = Get-VM | select Name, VMHost | where { $_.VMHost -like $sourceHost }

foreach($vm in $VMs) {
    Write-Host $vm.Name
    Move-VM -VM $(Get-VM -Name $vm.Name) -Destination $sourceHost
}

#Disconnect from vCenter
$viServer | Disconnect-VIServer -Force:$true -Confirm:$false
