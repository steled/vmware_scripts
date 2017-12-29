if (!(Get-Module -Name  "VMware.VimAutomation.Core")){
	if (Test-Path "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"){
		. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
	} else {
		Write-Warning "Unable to find Module 'VMware.VimAutomation.Core' and can't load 'C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'"
		return
	}
}

#Variables to change
$vCenter = "vCenter"
$vmHostName = "Hostname"
$vSSName = "vSwitch2"

#Connect to vCenter
if (!($viServer = Connect-VIServer –Server $vCenter -Credential (Get-Credential -message "vCenter Login for $vCenter"))){
	Write-Warning "Unable to connect to VIServer. Script will be aborted.";  
	Write-warning $error[0].Exception.Message;
	return
}

$vSwitch = Get-VirtualSwitch -VMHost $vmHostName -Name $vSSName -Standard:$true

#Import vSSPGs from file
$vSSPGs = Import-Csv "C:\tmp\vSSPGs.csv"

#Create virtualportgroup
foreach ($vSSPG in $vSSPGs) {
    New-VirtualPortGroup -Name $vSSPG.Name -VirtualSwitch $vSwitch -VLanId $vSSPG.VLanId -Confirm:$false
}

#Disconnect from vCenter
$viServer | Disconnect-VIServer -Force:$true -Confirm:$false
