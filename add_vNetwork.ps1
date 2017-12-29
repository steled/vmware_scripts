# Change variables
$vmHostName = "Hostname"
$vSwitch0Name = "vSwitch0"

$vSwitch1Name = "vSwitch1"
$vSwitch2Name = "vSwitch2"

$vMotionIP = "192.168.0.1"
$vMotionMask = "255.255.255.0"

$vNetwork = Get-VMHostNetwork -VMHost $vmHostName

# Add "vmnic1" to "vSwitch0"
$vSwitch0 = Get-VirtualSwitch -VMHost $vmHostName -Name $vSwitch0Name
$pNic1 = Get-VMHostNetworkAdapter -VMHost $vmHostName -Physical -Name "vmnic1"
Add-VirtualSwitchPhysicalNetworkAdapter -VirtualSwitch $vSwitch0 -VMHostPhysicalNic $pNic1 -Confirm:$false

# Remove PortGroup "VM Network" from "vSwitch0"
$vPortGroup = Get-VirtualPortGroup -VMHost $vmHostName -Name "VM Network"
Remove-VirtualPortGroup -VirtualPortGroup $vPortGroup -Confirm:$false

# Create "vSwitch1" and add "vmnic2" and "vmnic3"
$vSwitch1 = New-VirtualSwitch -VMHost $vmHostName -Name $vSwitch1Name -Nic vmnic2,vmnic3 -Confirm:$false
# Create PortGroup "vMotion", add PortGroup to "vSwitch1" and assign IP and SubnetMask
New-VMHostNetworkAdapter -VMHost $vmHostName -PortGroup "vMotion" -VirtualSwitch $vSwitch1 -IP $vMotionIP -SubnetMask $vMotionMask -VMotionEnabled:$true

# Create new "vSwitch2"
New-VirtualSwitch -VMHost $vmHostName -Name $vSwitch2Name -Nic vmnic4,vmnic5 -Confirm:$false
