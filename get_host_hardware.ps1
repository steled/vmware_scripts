if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
   ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

$vCenter = @("vCenter_1","vCenter_2")

foreach ($vCntr in $vCenter) {
	Connect-VIServer -Server $vCntr

	Get-VMHost | Get-View | Select @{N="Physical Machine Name";E={$_.Name}}, @{N=“Server Make and Model“;E={$_.Hardware.SystemInfo.Vendor+ “ “ + $_.Hardware.SystemInfo.Model}}, @{N=“Processor Model and Speed (Mhz)“;E={$_.Hardware.CpuPkg[0].Description}}, @{N=“# Physical CPUs“;E={$_.Hardware.CpuInfo.NumCpuPackages}}, @{N="# Cores per Physical CPU";E={$_.Hardware.CpuInfo.NumCpuCores}} | Export-Csv -Append -Path C:\Users\USERNAME\Desktop\hostinfo.csv

	Disconnect-VIServer -Confirm:$false
}
