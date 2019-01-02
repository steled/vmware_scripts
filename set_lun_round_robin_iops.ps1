# Quelle: https://kb.vmware.com/s/article/2069356
$CanonicalName = "naa.xxx"

$AllHosts = Get-Cluster "<CLUSTER-NAME>" | Get-VMHost | where {($_.ConnectionState -like "Connected")}
$AllHosts

foreach ($esxhost in $AllHosts) {Get-VMHost $esxhost | Get-ScsiLun -LunType disk | Where-Object {$_.Multipathpolicy -like "RoundRobin"} | Select-Object CanonicalName, MultipathPolicy, CommandsToSwitchPath}
foreach ($esxhost in $AllHosts) {Get-VMHost $esxhost | Get-ScsiLun -LunType disk | Where-Object {$_.Multipathpolicy -like "RoundRobin"} | Set-ScsiLun -CommandsToSwitchPath 1 | Select-Object CanonicalName, MultipathPolicy, CommandsToSwitchPath}

foreach ($esxhost in $AllHosts) {Get-VMHost $esxhost | Get-ScsiLun -LunType disk | Where-Object {$_.Multipathpolicy -like "RoundRobin" -and $_.CanonicalName -eq $CanonicalName} | Select-Object CanonicalName, MultipathPolicy, CommandsToSwitchPath}
foreach ($esxhost in $AllHosts) {Get-VMHost $esxhost | Get-ScsiLun -LunType disk | Where-Object {$_.Multipathpolicy -like "RoundRobin" -and $_.CanonicalName -eq $CanonicalName} | Set-ScsiLun -CommandsToSwitchPath 1 | Select-Object CanonicalName, MultipathPolicy, CommandsToSwitchPath}