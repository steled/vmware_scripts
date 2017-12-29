if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
 }
 
 $vCenter = "vCenter"
 #$esxHost = "ESXHost"
 #$esx = Get-VMHost -Name $esxHost
 
 $newFrags = @()
 $frags = @()
 $body = @()
 $frag5 = $null
 $frag6 = $null
 $frag7 = $null
 $frag8 = $null
 
 $mP = "Round Robin"
 $sSW = "0"
 $sFS = "0"
 $lH = "udp://xxx.xxx.xxx.xxx:514"
 $pM = "Reject"
 $mAC = "Accept"
 $fT = "Accept"
 $tS = "Enabled"
 $lB = "Route based on the originating virtual port ID"
 $nFD = "Link status only"
 $nS = "Yes"
 $f = "Yes"
 $vI = "0"
 $nDSP = "Start and stop with host"
 $nDS = "Running"
 $nCF = "Enabled"
 $sSSP = "Start and stop with host"
 $sSS = "Running"
 $sF = "Enabled"
 
 $suppressShellWarning = "0"
 $shareForceSalting = "0"
 $logHost = "udp://xxx.xxx.xxx.xxx:514"
 $allowPromiscuous = "False" # Reject
 $macChanges = "True" # Accept
 $forgedTransmits = "True" # Accept
 $shapingPolicy = "False" # Enabled
 $loadBalancingPolicy = "LoadBalanceSrcId" # Route based on the originating virtual port ID
 $networkFailoverDetectionPolicy = "LinkStatus" # Link status only
 $notifySwitches = "True" # Yes
 $failbackEnabled = "True" # Yes
 $vlanId = "0"
 $ntpdPolicy = "on" # Start and stop with host
 $ntpdRunning = "True" # Running
 $ntpFirewall = "True" # Enabled
 $vmsyslogdPolicy = "on" # Start and stop with host
 $vmsyslogdRunning = "True" # "Running"
 $syslogFirewall = "True" # Enabled
 
 Connect-VIServer -Server $vCenter
 
 function getSettings {
     param($vHost)
 
     $frag1 = $null
     $frag2 = $null
     $frag3 = $null
     $frag4 = $null
 
     $multiPath = @()
     # Get MultipathPolicy Not Like RoundRobin
     $multiPath += $vHost | where {$_.ConnectionState -eq "Connected"} | Get-ScsiLun -LunType disk | where {$_.MultipathPolicy -ne "RoundRobin"} | select @{N="Runtime Name";E={$_.RuntimeName}}, @{N="Multipath Policy";E={"Wrong $($_.MultipathPolicy)"}}
 
     # Get MultipathPolicy Like RoundRobin
     $multiPath += $vHost | where {$_.ConnectionState -eq "Connected"} | Get-ScsiLun -LunType disk | where {$_.MultipathPolicy -eq "RoundRobin"} | select @{N="Runtime Name";E={$_.RuntimeName}}, @{N="Multipath Policy";E={"OK $mP"}}
 
     $advSettings = @()
     # Get AdvancedSetting SuppressShellWarning
     $advSettings += Get-AdvancedSetting -Entity ($vHost | where {$_.ConnectionState -eq "Connected"}) -Name UserVars.SuppressShellWarning | select @{N="Setting Name";E={$_.Name}}, @{N="Setting Value";E={if($_.Value -eq $suppressShellWarning ){"OK $sSW"}else{"Wrong $($_.Value)"}}}
 
     # Get AdvancedSetting ShareForceSalting
     $advSettings += Get-AdvancedSetting -Entity ($vHost | where {$_.ConnectionState -eq "Connected"}) -Name Mem.ShareForceSalting | select @{N="Setting Name";E={$_.Name}}, @{N="Setting Value";E={$_.Value}}
 
     # Get AdvancedSetting logHost
     $advSettings += Get-AdvancedSetting -Entity ($vHost | where {$_.ConnectionState -eq "Connected"}) -Name Syslog.global.logHost | select @{N="Setting Name";E={$_.Name}}, @{N="Setting Value";E={if($_.Value -eq $logHost ){"OK $lH"}else{"Wrong $($_.Value)"}}}
 
     $secProfileService = @()
     $secProfileService += Get-VMHostService -VMHost $vHost | where {$_.Key -eq "ntpd"} | select @{N="Label";E={$_.Label}}, @{N="Policy";E={if($_.Policy -eq $ntpdPolicy){"OK $nDSP"}else{"Wrong $($_.Policy)"}}}, @{N="Running";E={if($_.Running -eq $ntpdRunning){"OK $nDS"}else{"Wrong $($_.Running)"}}}
     $secProfileService += Get-VMHostService -VMHost $vHost | where {$_.Key -eq "vmsyslogd"} | select @{N="Label";E={$_.Label}}, @{N="Policy";E={if($_.Policy -eq $vmsyslogdPolicy){"OK $sSSP"}else{"Wrong $($_.Policy)"}}}, @{N="Running";E={if($_.Running -eq $ntpdRunning){"OK $sSS"}else{"Wrong $($_.Running)"}}}
 
     $secProfileFirewall = @()
     $secProfileFirewall += Get-VMHostFirewallException -VMHost $vHost | where {$_.Name -eq 'NTP Client'} | select @{N="Name";E={$_.Name}}, @{N="Enabled";E={if($_.Enabled -eq $ntpFirewall){"OK $nCF"}else{"Wrong $($_.Enabled)"}}}
     $secProfileFirewall += Get-VMHostFirewallException -VMHost $vHost | where {$_.Name -eq 'syslog'} | select @{N="Name";E={$_.Name}}, @{N="Enabled";E={if($_.Enabled -eq $syslogFirewall){"OK $sF"}else{"Wrong $($_.Enabled)"}}}
 
     $frag1 = $multiPath | ConvertTo-Html -As Table -Fragment -PreContent "<h2 id=`"$($vHost.Name)`">$($vHost.Name)</h2><h3>Multipath Policy</h3>" | Out-String
     $frag2 = $secProfileService | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Security Profile - Services</h3>" | Out-String
     $frag3 = $secProfileFirewall | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Security Profile - Firewall</h3>" | Out-String
     $frag4 = $advSettings | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Advanced Settings</h3>" | Out-String
     $frag1
     $frag2
     $frag3
     $frag4
 }
 
 function getSwitchConf {
     param($vSwitch, $vHost)
 
     $networkSettings = @()
     $vNicTab = @{}
     $vHost.ExtensionData.Config.Network.Vnic | %{
         $vNicTab.Add($_.Portgroup,$_)
     }
 
     $vsw = Get-VirtualSwitch -VMHost $vHost -Name $vSwitch
     $vhn = Get-VMHostNetwork -VMHost $vHost
     $ntp = Get-NicTeamingPolicy -VirtualSwitch $vsw
 
     foreach($vpg in (Get-VirtualPortGroup -VirtualSwitch $vsw)){
         if($vsw.Name -ne "vSwitch2"){
             $networkSettings += Select -InputObject $vpg -Property @{N="ESX";E={$vHost.name}},
                 @{N="vSwitch";E={$vsw.Name}},
                 @{N="Promiscuous Mode";E={if($vsw.ExtensionData.Spec.Policy.Security.AllowPromiscuous.ToString() -eq $allowPromiscuous){"OK $pM"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.AllowPromiscuous.ToString())"}}},
                 @{N="MAC Address Changes";E={if($vsw.ExtensionData.Spec.Policy.Security.MacChanges -eq $macChanges){"OK $mAC"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.MacChanges)"}}},
                 @{N="Forged Transmits";E={if($vsw.ExtensionData.Spec.Policy.Security.ForgedTransmits -eq $forgedTransmits){"OK $fT"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.ForgedTransmits)"}}},
                 @{N="Traffic Shaping";E={if($vsw.ExtensionData.Spec.Policy.ShapingPolicy.Enabled.ToString() -eq $shapingPolicy){"OK $tS"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.ShapingPolicy.Enabled.ToString())"}}},
                 @{N="Load Balancing";E={if($ntp.LoadBalancingPolicy -eq $loadBalancingPolicy){"OK $lB"}else{"Wrong $($ntp.LoadBalancingPolicy)"}}},
                 @{N="Network Failover Detection";E={if($ntp.NetworkFailoverDetectionPolicy -eq $networkFailoverDetectionPolicy){"OK $nFD"}else{"Wrong $($ntp.NetworkFailoverDetectionPolicy)"}}},
                 @{N="Notify Switches";E={if($ntp.NotifySwitches -eq $notifySwitches){"OK $nS"}else{"Wrong $($ntp.NotifySwitches)"}}},
                 @{N="Failback";E={if($ntp.FailbackEnabled -eq $failbackEnabled){"OK $f"}else{"Wrong $($ntp.FailbackEnabled)"}}},
                 @{N="Network Adapters";E={if($vSwitch -eq "vSwitch0" -and $vsw.Nic -contains "vmnic0" -and "vmnic1"){"OK $($vsw.Nic)"}elseif($vSwitch -eq "vSwitch1" -and $vsw.Nic -contains "vmnic2" -and "vmnic3"){"OK $($vsw.Nic)"}else{"Wrong $($vsw.Nic)"}}},
                 @{N="Active Adapters";E={if($vSwitch -eq "vSwitch0" -and $ntp.ActiveNic -contains "vmnic0" -and "vmnic1"){"OK $($ntp.ActiveNic)"}elseif($vSwitch -eq "vSwitch1" -and $ntp.ActiveNic -contains "vmnic2" -and "vmnic3"){"OK $($ntp.ActiveNic)"}else{"Wrong $($ntp.ActiveNic)"}}},
                 @{N="Portgroup";E={if($vSwitch -eq "vSwitch0" -and $vpg.Name -eq "Management Network"){"OK $($vpg.Name)"}elseif($vSwitch -eq "vSwitch1" -and $vpg.Name -eq "vMotion"){"OK $($vpg.Name)"}else{"Wrong $($vpg.Name)"}}},
                 @{N="VLAN";E={if($vpg.VLanId -eq "$vlanId"){"OK $vI"}else{"Wrong $($vpg.VLanId)"}}},
                 @{N="Device";E={if($vSwitch -eq "vSwitch0" -and $vNicTab.ContainsKey("Management Network") -and $vNicTab["Management Network"].Device -eq "vmk0"){"OK $($vNicTab["Management Network"].Device)"}elseif($vSwitch -eq "vSwitch1" -and $vNicTab.ContainsKey("vMotion") -and $vNicTab["vMotion"].Device -eq "vmk1"){"OK $($vNicTab["vMotion"].Device)"}else{"Wrong"}}},
                 @{N="IP Address";E={if($vNicTab.ContainsKey($vpg.Name)){$vNicTab[$vpg.Name].Spec.Ip.IpAddress}}},
                 @{N="Subnet Mask";E={if($vNicTab.ContainsKey($vpg.Name)){$vNicTab[$vpg.Name].Spec.Ip.SubnetMask}}},
                 @{N="VMkernel Default Gateway";E={$vhn.VMKernelGateway}},
                 @{N="DNS Server Address";E={$vhn.DnsAddress}},
                 @{N="Domain";E={$vhn.DomainName}},
                 @{N="Search Domain";E={$vhn.SearchDomain}}
         } else {
             $networkSettings += Select -InputObject $vpg -Property @{N="ESX";E={$vHost.name}},
                 @{N="vSwitch";E={$vsw.Name}},
                 @{N="Promiscuous Mode";E={if($vsw.ExtensionData.Spec.Policy.Security.AllowPromiscuous.ToString() -eq $allowPromiscuous){"OK $pM"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.AllowPromiscuous.ToString())"}}},
                 @{N="MAC Address Changes";E={if($vsw.ExtensionData.Spec.Policy.Security.MacChanges -eq $macChanges){"OK $mAC"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.MacChanges)"}}},
                 @{N="Forged Transmits";E={if($vsw.ExtensionData.Spec.Policy.Security.ForgedTransmits -eq $forgedTransmits){"OK $fT"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.ForgedTransmits)"}}},
                 @{N="Traffic Shaping";E={if($vsw.ExtensionData.Spec.Policy.ShapingPolicy.Enabled.ToString() -eq $shapingPolicy){"OK $tS"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.ShapingPolicy.Enabled.ToString())"}}},
                 @{N="Load Balancing";E={if($ntp.LoadBalancingPolicy -eq $loadBalancingPolicy){"OK $lB"}else{"Wrong $($ntp.LoadBalancingPolicy)"}}},
                 @{N="Network Failover Detection";E={if($ntp.NetworkFailoverDetectionPolicy -eq $networkFailoverDetectionPolicy){"OK $nFD"}else{"Wrong $($ntp.NetworkFailoverDetectionPolicy)"}}},
                 @{N="Notify Switches";E={if($ntp.NotifySwitches -eq $notifySwitches){"OK $nS"}else{"Wrong $($ntp.NotifySwitches)"}}},
                 @{N="Failback";E={if($ntp.FailbackEnabled -eq $failbackEnabled){"OK $f"}else{"Wrong $($ntp.FailbackEnabled)"}}},
                 @{N="Network Adapters";E={if($vsw.Nic -contains "vmnic4" -and "vmnic5"){"OK $($vsw.Nic)"}else{"Wrong $($vsw.Nic)"}}},
                 @{N="Active Adapters";E={if($ntp.ActiveNic -contains "vmnic4" -and "vmnic5"){"OK $($ntp.ActiveNic)"}else{"Wrong $($ntp.ActiveNic)"}}}
             break
         }
     }
     $networkSettings
 }
 
 foreach($esx in Get-VMHost){
     $cli = Get-EsxCli -VMHost $esx
 #$test = @()
 #$test += $cli.network.ip.get() | select @{N="ESX";E={$esx.name}},@{N="IPv6 Enabled";E={if($_.IPv6Enabled -eq "false"){"OK $($_.IPv6Enabled)"}else{"Wrong $($_.IPv6Enabled)"}}}
 
 #$frag1 = $multiPath | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Multipath Policy</h2>" | Out-String
 #$frag2 = $secProfileService | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Security Profile - Services</h2>" | Out-String
 #$frag3 = $secProfileFirewall | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Security Profile - Firewall</h2>" | Out-String
 #$frag4 = $advSettings | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Advanced Settings</h2>" | Out-String
     if ($esx.ConnectionState -eq "Connected") {
         $frag50 = getSettings -vHost $esx
     }
     $frag5 = $cli.network.ip.get() | select @{N="ESX";E={$esx.name}},@{N="IPv6 Enabled";E={if($_.IPv6Enabled -eq "false"){"OK $($_.IPv6Enabled)"}else{"Wrong $($_.IPv6Enabled)"}}} | ConvertTo-Html -As List -Fragment -PreContent "<h2>Network Settings</h2>" | Out-String
     if ($(Get-VirtualSwitch -VMHost $esx).Name -contains "vSwitch0" -and $($(Get-VMHost -Name $esx).ExtensionData.Config.Network.Vnic).Portgroup -contains "Management Network") {
         $frag6 = getSwitchConf -vSwitch vSwitch0 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch0</h4>" | Out-String
     } else {
         $frag6 = ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch0</h4>" | Out-String
     }
     if ($(Get-VirtualSwitch -VMHost $esx).Name -contains "vSwitch1" -and $($(Get-VMHost -Name $esx).ExtensionData.Config.Network.Vnic).Portgroup -contains "vMotion") {
         $frag7 = getSwitchConf -vSwitch vSwitch1 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch1</h4>" | Out-String
     } else {
         $frag7 = ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch1</h4>" | Out-String
     }
     if ($(Get-VirtualSwitch -VMHost $esx).Name -contains "vSwitch2") {
         $frag8 = getSwitchConf -vSwitch vSwitch2 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch2</h4>" | Out-String
     } else {
         $frag8 = ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch2</h4>" | Out-String
     }
 
     $colorTagTable = @{OK = ' bgcolor="#00ff00">';
                    Wrong = ' bgcolor="#ff0000">'}
 #$frags = @($frag1,$frag2,$frag3,$frag4,$frag5,$frag6,$frag7,$frag8)
     $frags = @($frag50,$frag5,$frag6,$frag7,$frag8)
     $newFrags += @()
 
     foreach ($frag in $frags){
         $colorTagTable.Keys | foreach {$frag = $frag -replace ">$_ ",($colorTagTable.$_)}
         $newFrags += $frag
     }
     $body += "<a href=`"#$($esx.Name)`">$($esx.Name)</a><br>"
 }
 
 $head = "<style>"
 $head += "body { background-color:#dddddd; font-family:Tahoma; font-size:12pt; }"
 $head += "td, th { border:1px solid black; border-collapse:collapse; }"
 $head += "th { color:white; background-color:black; }"
 $head += "table, tr, td, th { padding: 2px; margin: 0px }"
 $head += "table { margin-left:50px; }"
 $head += "</style>"
 
 ConvertTo-Html -Head $head -Body "<h1>$($vCenter)</h1>$body" -PostContent $newFrags > C:\tmp\$($vCenter).htm
 Disconnect-VIServer -Confirm:$false