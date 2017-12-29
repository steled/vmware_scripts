if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
   ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

#Variables to change
$vCenter = "vCenter"
$vmHostNameSrc = "Source_Hostname"
$vmHostNameDst = "Destination_Hostname"
$vSSName = "vSwitch2"

#Connect to vCenter
if (!($viServer = Connect-VIServer -Server $vCenter -Credential (Get-Credential -message "vCenter Login for $vCenter") -ErrorAction SilentlyContinue)){
	Write-Warning "Unable to connect to VIServer. Script will be aborted."
	Write-warning $error[0].Exception.Message
	return
}

$vSwitchSrc = Get-VirtualSwitch -VMHost $vmHostNameSrc -Name $vSSName -Standard:$true
$vSwitchDst = New-VirtualSwitch -VMHost $vmHostNameDst -Name $vSSName -Nic vmnic4,vmnic5

#Export vSSPGs
$vSSPGsrc = Get-VirtualPortGroup -VirtualSwitch $vSwitchSrc | select Name, VLanId

#Create virtualportgroup
foreach ($vSSPG in $vSSPGsrc) {
    New-VirtualPortGroup -Name $vSSPG.Name -VirtualSwitch $vSwitchDst -VLanId $vSSPG.VLanId -Confirm:$false
}

#Disconnect from vCenter
$viServer | Disconnect-VIServer -Force:$true -Confirm:$false
