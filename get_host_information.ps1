if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 $col = @()
 
 Connect-VIServer -Server $vCenter
 
 foreach ($cluster in Get-Cluster) {
     foreach ($esx in ($cluster | Get-VMHost)) {
         $item = New-Object PSObject
 
         $hostView = $esx | Get-View
         $item | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $esx.Name
         $item | Add-Member -MemberType NoteProperty -Name "ProcessorType" -Value $hostView.Hardware.CpuPkg[0].Description
         $item | Add-Member -MemberType NoteProperty -Name "Sockets" -Value $hostView.hardware.cpuinfo.numCpuPackages #$hostView.Hardware.CpuPkg[0].Description
         $item | Add-Member -MemberType NoteProperty -Name "CoresPerSocket" -Value $($hostView.Hardware.CpuInfo.NumCpuCores/2)
         $item | Add-Member -MemberType NoteProperty -Name "Memory" -Value $([math]::Round($esx.MemoryTotalGB)) #$hostView.hardware.memorysize/1024Mb
         $item | Add-Member -MemberType NoteProperty -Name "Model" -Value $esx.Model
 
         foreach ($hba in Get-VMHostHba -VMHost $esx) {
             $hbaDevice = $hba | select Device
             $hbaModel = $hba | select Model
             $item | Add-Member -MemberType NoteProperty -Name $hbaDevice.Device.Normalize() -Value $hbaModel.Model.Normalize()
         }
 
         foreach ($nic in $($(Get-EsxCli -VMHost $esx -V2).network.nic.list.Invoke())) {
             $item | Add-Member -MemberType NoteProperty -Name $nic.Name -Value $nic.Description
         }
         $col += $item
     }
 }
 $col | Export-Csv C:\Users\USER\Desktop\host_information.csv -NoTypeInformation #| Out-GridView
 $col = @()
 
 Disconnect-VIServer -Confirm:$false