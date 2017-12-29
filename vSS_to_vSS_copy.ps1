if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
   ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

#Variables to change
$vCenter = "vCenter"
$vmHostNameSrc = "Source_Hostname"
$vmHostNameDst = "Destination_Hostname"
$vSSName = "vSwitch2"

Connect-VIServer -Server $vCenter
$vSwitchSrc = Get-VirtualSwitch -VMHost $vmHostNameSrc -Name $vSSName -Standard:$true
if (!(Get-VirtualSwitch -VMHost $vmHostNameDst -Name $vSSName -Standard:$true)) {
    $vSwitchDst = New-VirtualSwitch -VMHost $vmHostNameDst -Name $vSSName -Nic vmnic4,vmnic5
} else {
    $vSwitchDst = Get-VirtualSwitch -VMHost $vmHostNameDst -Name $vSSName -Standard:$true
}

#Export vSSPGs
$vSSPGsrc = Get-VirtualPortGroup -VirtualSwitch $vSwitchSrc | select Name, VLanId

#Create virtualportgroup
foreach ($vSSPG in $vSSPGsrc) {
    New-VirtualPortGroup -Name $vSSPG.Name -VirtualSwitch $vSwitchDst -VLanId $vSSPG.VLanId -Confirm:$false
}

Disconnect-VIServer -Confirm:$false
