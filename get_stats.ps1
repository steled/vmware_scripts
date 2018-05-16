if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 $esxHosts = @("host")
 $startTime = "13/05/2018"
 $endTime = "14/05/2018"
 $interval = "1800"
 
 $credential = Get-Credential -message "vCenter Login for $vCenter"
 
 #Connect to vCenter
 if (!($viServer = Connect-VIServer –Server $vCenter -Credential $credential)) {
     Write-Warning "Unable to connect to VIServer. Script will be aborted.";  
     Write-warning $error[0].Exception.Message;
     return
 }
 
 $vms = Get-VM
 $col = @()
 foreach ($vm in $vms) {
     foreach ($timestamp in $(Get-Stat -Entity $vm -Stat "cpu.usage.average" -Start $startTime -Finish $endTime -IntervalSecs $interval).Timestamp) {
         $item = New-Object PSObject
         $item | Add-Member -MemberType NoteProperty -Name "name" -Value $vm.Name
         $item | Add-Member -MemberType NoteProperty -Name "time" -Value $timestamp.ToString()
         foreach ($value in Get-Stat -Entity $vm -Stat "cpu.usage.average","mem.usage.average","net.usage.average" -Start $startTime -Finish $endTime -IntervalSecs $interval) {
             if($timestamp -eq $value.Timestamp -and $value.MetricId -eq "cpu.usage.average") {
                 $item | Add-Member -MemberType NoteProperty -Name "cpu" -Value ($value.Value.ToString() | where {$timestamp -eq $value.Timestamp -and $value.MetricId -eq "cpu.usage.average"})
             }
             if($timestamp -eq $value.Timestamp -and $value.MetricId -eq "mem.usage.average") {
                 $item | Add-Member -MemberType NoteProperty -Name "mem" -Value ($value.Value.ToString() | where {$timestamp -eq $value.Timestamp -and $value.MetricId -eq "mem.usage.average"})
             }
             if($timestamp -eq $value.Timestamp -and $value.MetricId -eq "net.usage.average") {
                 $item | Add-Member -MemberType NoteProperty -Name "net" -Value ($value.Value.ToString() | where {$timestamp -eq $value.Timestamp -and $value.MetricId -eq "net.usage.average"})
             }
         }
         $col += $item
     }
 }
 
 $col #|ft -AutoSize | Out-GridView
 
 Disconnect-VIServer -Confirm:$false