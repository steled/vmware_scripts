# Load vSphere PowerCLI
if (!(Get-Module -Name "VMware.VimAutomation.Core")) {
    if (Test-Path "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1") {
        ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
    } else {
        Write-Warning "Unable to find Module 'VMware.VimAutomation.Core' and can't load 'C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'"
        return
    }
}

$datastore = "DATASTORE"
$vibPath = @("/vmfs/volumes/$datastore/VIB/VMware_bootbank_esx-base_6.0.0-3.76.6856897.vib","/vmfs/volumes/$datastore/VIB/VMware_bootbank_vsan_6.0.0-3.76.6769077.vib","/vmfs/volumes/$datastore/VIB/VMware_bootbank_vsanhealth_6.0.0-3000000.3.0.3.76.6769078.vib")
$vCenter = "VCENTER"
$esxHosts = @("ESXHOST")


#Connect to VIServer
if (!($viServer = Connect-VIServer -Server $server -Credential (Get-Credential -Message "Login for $server") -ErrorAction SilentlyContinue)){
    Write-Warning "Unable to connect to VIServer. Script will be aborted."
    Write-warning $error[0].Exception.Message
    return
}

foreach ($esxHost in $esxHosts) {
    $esxCli = Get-EsxCli -VMHost $esxHost
    $esxCli.software.vib.install($null,$null,$null,$null,$null,$true,$null,$null,$vibPath)
    Restart-VMHost -VMHost $esxHost -Confirm:$false
}

#Disconnect from VIServer
$viServer | Disconnect-VIServer -Force:$true -Confirm:$false