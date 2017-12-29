# get Device, Type, Model, Driver & DriverVersion for all HBAs on Host
function getHostHBAs($vmHost) {

    $vmHBAs = Get-VMHost -Name $vmHost | Get-VMHostHba
    #$allInfo = @()
    foreach ($vmHBA in $vmHBAs) {
        $esxCli = $vmHBA.VMHost | Get-EsxCli -V2

        $info = "" | Select VMHost, Device, Type, Model, Driver, DriverVersion
        $info.VMHost = $vmHBA.VMHost
        $info.Device = $vmHBA.Device
        $info.Type = $vmHBA.Type
        $info.Model = $vmHBA.Model
        $info.Driver = $vmHBA.Driver
        $info.DriverVersion = $($esxCli.software.vib.get.Invoke(@{vibname = $vmHBA.Driver })).Version

        $global:allInfo += $info
    }

    #$allInfo | select VMHost, Device, Type, Model, Driver, DriverVersion | ft -AutoSize
}

# get Device, Type, Model, Driver, DriverVersion & Firmwareversion for all NICs on Host
function getHostNICs($vmHost) {

    $vmNICs = Get-VMHost -Name $vmHost | Get-VMHostPciDevice | where { $_.DeviceClass -eq "NetworkController" }
    #$allInfo = @()
    foreach ($vmNIC in $vmNICs) {
        $esxCli = $vmNIC.VMHost | Get-EsxCli -V2

        $nicList = $esxCli.network.nic.list.Invoke();
        $vmNICId = $nicList | where { $_.PCIDevice -like '*' + $vmNIC.Id }
        $vmNICDetail = $esxCli.network.nic.get.Invoke(@{nicname = $vmNICId.Name})

        $info = "" | Select VMHost, Device, Type, Model, Driver, DriverVersion, Firmwareversion
        $info.VMHost = $vmNIC.VMHost
        $info.Type = $vmNIC.DeviceClass
        $info.Device = $vmNICId.Name
        $info.Model = $($nicList | where { $_.PCIDevice -like '*' + $vmNIC.Id }).Description
        $info.Driver = $vmNICDetail.DriverInfo.Driver
        $info.DriverVersion = $vmNICDetail.DriverInfo.Version
        $info.FirmwareVersion = $vmNICDetail.DriverInfo.FirmwareVersion

        $global:allInfo += $info
    }

    #$allInfo | select VMHost, Device, Type, Model, Driver, DriverVersion, Firmwareversion | ft -AutoSize
}

$global:allInfo = @()
$vmHosts = Get-VMHost
foreach ($vmHost in $vmHosts) {
    getHostHBAs($vmHost)
    getHostNICs($vmHost)
}
$allInfo | select VMHost, Device, Type, Model, Driver, DriverVersion, Firmwareversion | ft -AutoSize
