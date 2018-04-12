if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 $csv = "CSV"
 
 Connect-VIServer -Server $vCenter
 
 $out = @()
 $VMs = Get-VM
 foreach ($VM in $VMs) {
     $VMx = Get-View $VM.ID
     $HW = $VMx.guest.net
     foreach ($dev in $HW) {
         foreach ($ip in $dev.ipaddress) {
             #$out += $dev | select @{Name = "Name"; Expression = {$vm.name}}, @{Name = "UUID"; Expression={%{(Get-View $vm.Id).config.uuid}}}, @{Name = "IP"; Expression = {$ip}}, @{Name = "MAC"; Expression = {$dev.macaddress}} | Where-Object {$ip -notlike "fe80*"}
             $out += $dev | Select-Object @{Name = "Name"; Expression = {$vm.name}}, @{Name = "ID"; Expression={$vm.Id}}, @{Name = "IP"; Expression = {$ip}}, @{Name = "MAC"; Expression = {$dev.macaddress}} | Where-Object {$ip -notlike "fe80*"}
         }
     }
 }
 
 $out | ft #| Export-Csv -NoTypeInformation -Append -Path $csv
 
 Disconnect-VIServer -Confirm:$false