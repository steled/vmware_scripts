if ( !(Get-Module -Name VMware.VimAutomation.Core) ) {
    ."C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

$vCenter = "vCenter"
#$esxHost = "ESXHost"
#$esx = Get-VMHost -Name $esxHost
$outFile = "C:\temp\$($vCenter).htm"

$newFrags = @()
$content = @()
$frags = @()
$body = @()
$frag6 = $null
$frag7 = $null
$frag8 = $null
$frag9 = $null

$managementPortgroup = "*MGMT*"
$vMotionPortgroup = "*VMOTION*"

$mP = "Round Robin"
$sSW = "0" #suppressShellWarning
$sFS = "0" #shareForceSalting
$lH = "udp://xxx.xxx.xxx.xxx:514" #logHost
$eSIT = "900" #esxiShellInteractiveTimeOut
$eST = "900" #esxiShellTimeOut
$pM = "Reject" #allowPromiscuous
$mAC = "Accept" #macChanges
$fT = "Accept" #forgedTransmits
$tS = "Enabled" #shapingPolicy
$lB = "Route based on the originating virtual port ID" #loadBalancingPolicy
$nFD = "Link status only" #networkFailoverDetectionPolicy
$nS = "Yes" #notifySwitches
$f = "Yes" #failbackEnabled
$vI = "0" #vlanId
$ntpS = "xxx"
$nDSP = "Start and stop with host" #ntpdPolicy
$nDS = "Running" #ntpdRunning
$nCF = "Enabled" #ntpFirewall
$sSSP = "Start and stop with host" #vmsyslogdPolicy
$sSS = "Running" #vmsyslogdRunning
$dcuiP = "Start and stop with host" #dcuiPolicy
$dcui = "Running" #dcuiRunning
$tsmP = "Start and stop manually" #tsmPolicy
$tsm = "Stopped" #tsmRunning
$tsmSshP = "Start and stop manually" #tsmPolicy
$tsmSsh = "Stopped" #tsmRunning
$sF = "Enabled" #syslogFirewall
$lockdownS = "Enabled" # lockdownStatus
$lockdownM = "Normal" # lockdownM
$ipv6S = "Disabled" # ipv6Status

$suppressShellWarning = "0"
$shareForceSalting = "0"
$logHost = "udp://xxx.xxx.xxx.xxx:514"
$esxiShellInteractiveTimeOut = "900"
$esxiShellTimeOut = "900"
$allowPromiscuous = "False" # Reject
$macChanges = "True" # Accept
$forgedTransmits = "True" # Accept
$shapingPolicy = "True" # Enabled
$loadBalancingPolicy = "LoadBalanceSrcId" # Route based on the originating virtual port ID
$networkFailoverDetectionPolicy = "LinkStatus" # Link status only
$notifySwitches = "True" # Yes
$failbackEnabled = "True" # Yes
$vlanId = "0"
$ntpServer = "xxx"
$ntpdPolicy = "on" # Start and stop with host
$ntpdRunning = "True" # Running
$ntpFirewall = "True" # Enabled
$vmsyslogdPolicy = "on" # Start and stop with host
$vmsyslogdRunning = "True" # "Running"
$dcuiPolicy = "on" # Start and stop with host
$dcuiRunning = "True" # Running
$tsmPolicy = "off" # Start and stop manually
$tsmRunning = "False" # Stopped
$tsmSshPolicy = "off" # Start and stop manually
$tsmSshRunning = "False" # Stopped
$syslogFirewall = "True" # Enabled
$lockdownStatus = "True" # Enabled
$lockdownMode = "lockdownNormal" # Normal
$ipv6Status = "False" # Disabled

Connect-VIServer -Server $vCenter

function getSettings {
    param($vHost)

#    $frag1 = $null
#    $frag2 = $null
#    $frag3 = $null
#    $frag4 = $null
#    $frag5 = $null
#    $frag6 = $null
    $tempContent = @()

    if ($vHost | Get-VMHostHba -Type "FibreChannel") {
       $multiPath = @()
       # Get MultipathPolicy Not Like RoundRobin
       $multiPath += $vHost | where {$_.ConnectionState -eq "Connected"} | Get-VMHostHba -Type "FibreChannel" | Get-ScsiLun -LunType disk | where {$_.MultipathPolicy -ne "RoundRobin"} | select @{N="Runtime Name";E={$_.RuntimeName}}, @{N="Multipath Policy";E={"Wrong $($_.MultipathPolicy)"}}
        # Get MultipathPolicy Like RoundRobin
        $multiPath += $vHost | where {$_.ConnectionState -eq "Connected"} | Get-VMHostHba -Type "FibreChannel" | Get-ScsiLun -LunType disk | where {$_.MultipathPolicy -eq "RoundRobin"} | select @{N="Runtime Name";E={$_.RuntimeName}}, @{N="Multipath Policy";E={"OK $mP"}}
    }

    $advSettings = @()
    # Get AdvancedSetting SuppressShellWarning
    $advSettings += Get-AdvancedSetting -Entity ($vHost | where {$_.ConnectionState -eq "Connected"}) -Name UserVars.SuppressShellWarning | select @{N="Setting Name";E={$_.Name}}, @{N="Setting Value";E={if($_.Value -eq $suppressShellWarning ){"OK $sSW"}else{"Wrong $($_.Value)"}}}

    # Get AdvancedSetting ShareForceSalting
    $advSettings += Get-AdvancedSetting -Entity ($vHost | where {$_.ConnectionState -eq "Connected"}) -Name Mem.ShareForceSalting | select @{N="Setting Name";E={$_.Name}}, @{N="Setting Value";E={if($_.Value -eq $shareForceSalting ){"OK $sFS"}else{"Wrong $($_.Value)"}}}

    # Get AdvancedSetting logHost
    $advSettings += Get-AdvancedSetting -Entity ($vHost | where {$_.ConnectionState -eq "Connected"}) -Name Syslog.global.logHost | select @{N="Setting Name";E={$_.Name}}, @{N="Setting Value";E={if($_.Value -eq $logHost ){"OK $lH"}else{"Wrong $($_.Value)"}}}

    # Get AdvancedSetting ESXiShellInteractiveTimeOut
    $advSettings += Get-AdvancedSetting -Entity ($vHost | where {$_.ConnectionState -eq "Connected"}) -Name UserVars.ESXiShellInteractiveTimeOut | select @{N="Setting Name";E={$_.Name}}, @{N="Setting Value";E={if($_.Value -eq $esxiShellInteractiveTimeOut ){"OK $eSIT"}else{"Wrong $($_.Value)"}}}

    # Get AdvancedSetting ESXiShellTimeOut
    $advSettings += Get-AdvancedSetting -Entity ($vHost | where {$_.ConnectionState -eq "Connected"}) -Name UserVars.ESXiShellTimeOut | select @{N="Setting Name";E={$_.Name}}, @{N="Setting Value";E={if($_.Value -eq $esxiShellTimeOut ){"OK $eST"}else{"Wrong $($_.Value)"}}}

    $secProfileService = @()
    $secProfileService += Get-VMHostService -VMHost $vHost | where {$_.Key -eq "ntpd"} | select @{N="Label";E={$_.Label}}, @{N="Policy";E={if($_.Policy -eq $ntpdPolicy){"OK $nDSP"}else{"Wrong $($_.Policy)"}}}, @{N="Running";E={if($_.Running.ToString() -eq $ntpdRunning){"OK $nDS"}else{"Wrong $($_.Running)"}}}
    $secProfileService += Get-VMHostService -VMHost $vHost | where {$_.Key -eq "vmsyslogd"} | select @{N="Label";E={$_.Label}}, @{N="Policy";E={if($_.Policy -eq $vmsyslogdPolicy){"OK $sSSP"}else{"Wrong $($_.Policy)"}}}, @{N="Running";E={if($_.Running.ToString() -eq $vmsyslogdRunning){"OK $sSS"}else{"Wrong $($_.Running)"}}}
    $secProfileService += Get-VMHostService -VMHost $vHost | where {$_.Key -eq "DCUI"} | select @{N="Label";E={$_.Label}}, @{N="Policy";E={if($_.Policy -eq $dcuiPolicy){"OK $dcuiP"}else{"Wrong $($_.Policy)"}}}, @{N="Running";E={if($_.Running.ToString() -eq $dcuiRunning){"OK $dcui"}else{"Wrong $($_.Running)"}}}
    $secProfileService += Get-VMHostService -VMHost $vHost | where {$_.Key -eq "TSM"} | select @{N="Label";E={$_.Label}}, @{N="Policy";E={if($_.Policy -eq $tsmPolicy){"OK $tsmP"}else{"Wrong $($_.Policy)"}}}, @{N="Running";E={if($_.Running.ToString() -eq $tsmRunning){"OK $tsm"}else{"Wrong $($_.Running)"}}}
    $secProfileService += Get-VMHostService -VMHost $vHost | where {$_.Key -eq "TSM-SSH"} | select @{N="Label";E={$_.Label}}, @{N="Policy";E={if($_.Policy -eq $tsmSshPolicy){"OK $tsmSshP"}else{"Wrong $($_.Policy)"}}}, @{N="Running";E={if($_.Running.ToString() -eq $tsmSshRunning){"OK $tsmSsh"}else{"Wrong $($_.Running)"}}}

    $secProfileFirewall = @()
    $secProfileFirewall += Get-VMHostFirewallException -VMHost $vHost | where {$_.Name -eq 'NTP-Client'} | select @{N="Name";E={$_.Name}}, @{N="Enabled";E={if($_.Enabled -eq $ntpFirewall){"OK $nCF"}else{"Wrong $($_.Enabled)"}}}
    $secProfileFirewall += Get-VMHostFirewallException -VMHost $vHost | where {$_.Name -eq 'syslog'} | select @{N="Name";E={$_.Name}}, @{N="Enabled";E={if($_.Enabled -eq $syslogFirewall){"OK $sF"}else{"Wrong $($_.Enabled)"}}}

    $secProfileLockdown = @()
    $secProfileLockdown += (Get-VMHost $vHost).ExtensionData.Config | select @{N="Status";E={if($_.AdminDisabled -eq $lockdownStatus ){"OK $lockdownS"}else{"Wrong $($_.AdminDisabled)"}}}, @{N="Lockdown Mode";E={if($_.LockdownMode -eq $lockdownMode){"OK $lockdownM"}else{"Wrong $($_.LockdownMode)"}}}

    $timeServer = @()
    $timeServer += Get-VMHostNtpServer -VMHost $vHost | select @{N="NTP Servers";E={if($_ -eq $ntpServer){"OK $ntpS"}else{"Wrong $($_)"}}}

#    $frag1 = $multiPath | ConvertTo-Html -As Table -Fragment -PreContent "<h2 id=`"$($vHost.Name)`">$($vHost.Name)</h2><h3>Multipath Policy</h3>" | Out-String
#    $frag2 = $secProfileService | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Security Profile - Services</h3>" | Out-String
#    $frag3 = $secProfileFirewall | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Security Profile - Firewall</h3>" | Out-String
#    $frag4 = $secProfileLockdown | ConvertTo-Html -As List -Fragment -PreContent "<h3>Security Profile - Lockdown Mode</h3>" | Out-String
#    $frag5 = $advSettings | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Advanced Settings</h3>" | Out-String
#    $frag6 = $timeServer | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Time Configuration</h3>" | Out-String
#    $frag6 = $frag6.Replace("<td>*:</td>","<td>NTP Servers:</td>")
#    $frag1
#    $frag2
#    $frag3
#    $frag4
#    $frag5
#    $frag6
    $tempContent += $multiPath | ConvertTo-Html -As Table -Fragment -PreContent "<h2 id=`"$($vHost.Name)`">$($vHost.Name)</h2><h3>Multipath Policy</h3>" | Out-String
    $tempContent += $secProfileService | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Security Profile - Services</h3>" | Out-String
    $tempContent += $secProfileFirewall | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Security Profile - Firewall</h3>" | Out-String
    $tempContent += $secProfileLockdown | ConvertTo-Html -As List -Fragment -PreContent "<h3>Security Profile - Lockdown Mode</h3>" | Out-String
    $tempContent += $advSettings | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Advanced Settings</h3>" | Out-String
#     $tempContent += $timeServer | ConvertTo-Html -As List -Fragment -PreContent "<h3>Time Configuration</h3>" | Out-String
    $timeServer = $timeServer | ConvertTo-Html -As List -Fragment -PreContent "<h3>Time Configuration</h3>" | Out-String
    $tempContent += $timeServer.Replace("<td>*:</td>","<td>NTP Servers:</td>")
#     $tempContent = $tempContent.Replace("<td>*:</td>","<td>NTP Servers:</td>")
    $tempContent
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
        #if($vsw.Name -ne "vSwitch2"){
        #if(($vpg.Name -like $managementPortgroup) -or ($vpg.Name -like $vMotionPortgroup)){
        if(($vpg.Name -eq $(Get-VMHostNetworkAdapter -VMHost $esx -VMKernel | where {$_.ManagementTrafficEnabled -eq $True} | select PortGroupName).PortGroupName) -or ($vpg.Name -eq $(Get-VMHostNetworkAdapter -VMHost $esx -VMKernel | where {$_.VMotionEnabled -eq $True} | select PortGroupName).PortGroupName)) {
            $networkSettings += Select -InputObject $vpg -Property @{N="ESX";E={$vHost.name}},
                @{N="vSwitch";E={$vsw.Name}},
                @{N="Promiscuous Mode";E={if($vsw.ExtensionData.Spec.Policy.Security.AllowPromiscuous.ToString() -eq $allowPromiscuous){"OK $pM"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.AllowPromiscuous.ToString())"}}},
                @{N="MAC Address Changes";E={if($vsw.ExtensionData.Spec.Policy.Security.MacChanges.ToString() -eq $macChanges){"OK $mAC"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.MacChanges)"}}},
                @{N="Forged Transmits";E={if($vsw.ExtensionData.Spec.Policy.Security.ForgedTransmits.ToString() -eq $forgedTransmits){"OK $fT"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.ForgedTransmits)"}}},
                @{N="Traffic Shaping";E={if($vsw.ExtensionData.Spec.Policy.ShapingPolicy.Enabled.ToString() -eq $shapingPolicy){"OK $tS"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.ShapingPolicy.Enabled.ToString())"}}},
                #@{N="Load Balancing";E={if($ntp.LoadBalancingPolicy -eq $loadBalancingPolicy){"OK $lB"}else{"Wrong $($ntp.LoadBalancingPolicy)"}}},
                @{N="Load Balancing";E={if($vsw.ExtensionData.Spec.Policy.NicTeaming.Policy -eq $loadBalancingPolicy){"OK $lB"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.NicTeaming.Policy)"}}},
                #@{N="Network Failover Detection";E={if($ntp.NetworkFailoverDetectionPolicy -eq $networkFailoverDetectionPolicy){"OK $nFD"}else{"Wrong $($ntp.NetworkFailoverDetectionPolicy)"}}},
                @{N="Network Failover Detection";E={if($ntp.NetworkFailoverDetectionPolicy -eq $networkFailoverDetectionPolicy){"OK $nFD"}else{"Wrong $($ntp.NetworkFailoverDetectionPolicy)"}}},
                #@{N="Notify Switches";E={if($ntp.NotifySwitches -eq $notifySwitches){"OK $nS"}else{"Wrong $($ntp.NotifySwitches)"}}},
                @{N="Notify Switches";E={if($vsw.ExtensionData.Spec.Policy.NicTeaming.NotifySwitches -eq $notifySwitches){"OK $nS"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.NicTeaming.NotifySwitches)"}}},
                @{N="Failback";E={if($ntp.FailbackEnabled -eq $failbackEnabled){"OK $f"}else{"Wrong $($ntp.FailbackEnabled)"}}},
                #@{N="Network Adapters";E={if(($vSwitch -eq "vSwitch0" -and $vsw.Nic -contains "vmnic0") -and ($vSwitch -eq "vSwitch0" -and $vsw.Nic -contains "vmnic2")){"OK $($vsw.Nic)"}elseif(($vSwitch -eq "vSwitch1" -and $vsw.Nic -contains "vmnic1") -and ($vSwitch -eq "vSwitch1" -and $vsw.Nic -contains "vmnic3")){"OK $($vsw.Nic)"}else{"Wrong $($vsw.Nic)"}}},
                #@{N="Network Adapters";E={$($vsw.Nic)}},
                @{N="Network Adapters";E={$($vsw.ExtensionData.Spec.Bridge.NicDevice)}},
                #@{N="Active Adapters";E={if(($vSwitch -eq "vSwitch0" -and $ntp.ActiveNic -contains "vmnic0") -and ($vSwitch -eq "vSwitch0" -and $ntp.ActiveNic -contains "vmnic2")){"OK $($ntp.ActiveNic)"}elseif(($vSwitch -eq "vSwitch1" -and $ntp.ActiveNic -contains "vmnic1") -and ($vSwitch -eq "vSwitch1" -and $vsw.Nic -contains "vmnic3")){"OK $($ntp.ActiveNic)"}else{"Wrong $($ntp.ActiveNic)"}}},
                #@{N="Active Adapters";E={$($ntp.ActiveNic)}},
                @{N="Active Adapters";E={$($vsw.ExtensionData.Spec.Policy.NicTeaming.NicOrder.ActiveNic)}},
                #@{N="Portgroup";E={if($vSwitch -eq "vSwitch0" -and $vpg.Name -like $managementPortgroup){"OK $($vpg.Name)"}elseif($vSwitch -eq "vSwitch1" -and $vpg.Name -like $vMotionPortgroup){"OK $($vpg.Name)"}else{"Wrong $($vpg.Name)"}}},
                #@{N="Portgroup";E={$($vpg.Name)}},
                @{N="Portgroup";E={$($vsw.ExtensionData.Portgroup -split ("key-vim.host.PortGroup-"))}},
                @{N="VLAN";E={if($vpg.VLanId -eq "$vlanId"){"OK $vI"}else{"Wrong $($vpg.VLanId)"}}},
                #@{N="Device";E={if($vSwitch -eq "vSwitch0" -and $vNicTab.Keys -like $managementPortgroup -and $vNicTab[$($vNicTab.Keys -like $managementPortgroup).ToString()].Device -eq "vmk0"){"OK $($vNicTab[$($vNicTab.Keys -like $managementPortgroup).ToString()].Device)"}elseif($vSwitch -eq "vSwitch1" -and $vNicTab.Keys -like $vMotionPortgroup -and $vNicTab[$($vNicTab.Keys -like $vMotionPortgroup).ToString()].Device -eq "vmk1"){"OK $($vNicTab[$($vNicTab.Keys -like $vMotionPortgroup).ToString()].Device)"}else{"Wrong"}}},
                @{N="Device";E={$($vNicTab[$vpg.Name]).Device}},
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
                @{N="MAC Address Changes";E={if($vsw.ExtensionData.Spec.Policy.Security.MacChanges.ToString() -eq $macChanges){"OK $mAC"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.MacChanges)"}}},
                @{N="Forged Transmits";E={if($vsw.ExtensionData.Spec.Policy.Security.ForgedTransmits.ToString() -eq $forgedTransmits){"OK $fT"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.Security.ForgedTransmits)"}}},
                @{N="Traffic Shaping";E={if($vsw.ExtensionData.Spec.Policy.ShapingPolicy.Enabled.ToString() -eq $shapingPolicy){"OK $tS"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.ShapingPolicy.Enabled.ToString())"}}},
                #@{N="Load Balancing";E={if($ntp.LoadBalancingPolicy -eq $loadBalancingPolicy){"OK $lB"}else{"Wrong $($ntp.LoadBalancingPolicy)"}}},
                @{N="Load Balancing";E={if($vsw.ExtensionData.Spec.Policy.NicTeaming.Policy -eq $loadBalancingPolicy){"OK $lB"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.NicTeaming.Policy)"}}},
                @{N="Network Failover Detection";E={if($ntp.NetworkFailoverDetectionPolicy -eq $networkFailoverDetectionPolicy){"OK $nFD"}else{"Wrong $($ntp.NetworkFailoverDetectionPolicy)"}}},
                #@{N="Notify Switches";E={if($ntp.NotifySwitches -eq $notifySwitches){"OK $nS"}else{"Wrong $($ntp.NotifySwitches)"}}},
                @{N="Notify Switches";E={if($vsw.ExtensionData.Spec.Policy.NicTeaming.NotifySwitches -eq $notifySwitches){"OK $nS"}else{"Wrong $($vsw.ExtensionData.Spec.Policy.NicTeaming.NotifySwitches)"}}},
                @{N="Failback";E={if($ntp.FailbackEnabled -eq $failbackEnabled){"OK $f"}else{"Wrong $($ntp.FailbackEnabled)"}}},
                #@{N="Network Adapters";E={if(($vsw.Nic -contains "vmnic4") -and ($vsw.Nic -contains "vmnic8")){"OK $($vsw.Nic)"}else{"Wrong $($vsw.Nic)"}}},
                @{N="Network Adapters";E={$($vsw.ExtensionData.Spec.Bridge.NicDevice)}},
                #@{N="Active Adapters";E={if(($ntp.ActiveNic -contains "vmnic4") -and ($ntp.ActiveNic -contains "vmnic8")){"OK $($ntp.ActiveNic)"}else{"Wrong $($ntp.ActiveNic)"}}}
                #@{N="Active Adapters";E={$($ntp.ActiveNic)}}
                @{N="Active Adapters";E={$($vsw.ExtensionData.Spec.Policy.NicTeaming.NicOrder.ActiveNic)}}
            break
        }
    }
    $networkSettings
}

#foreach($esx in Get-VMHost -Name $esxHost){
foreach($esx in Get-VMHost){
    $cli = Get-EsxCli -VMHost $esx -V2
    if ($esx.ConnectionState -eq "Connected") {
        #$frag50 = getSettings -vHost $esx
        $content += getSettings -vHost $esx
    }
    #$frag7 = $cli.network.ip.get.Invoke() | select @{N="ESX";E={$esx.name}},@{N="IPv6 Enabled";E={if($_.IPv6Enabled -eq $ipv6Status){"OK $ipv6S"}else{"Wrong $($_.IPv6Enabled)"}}} | ConvertTo-Html -As List -Fragment -PreContent "<h2>Network Settings</h2>" | Out-String
    $content += $cli.network.ip.get.Invoke() | select @{N="ESX";E={$esx.name}},@{N="IPv6 Enabled";E={if($_.IPv6Enabled -eq $ipv6Status){"OK $ipv6S"}else{"Wrong $($_.IPv6Enabled)"}}} | ConvertTo-Html -As List -Fragment -PreContent "<h2>Network Settings</h2>" | Out-String
#    if ($(Get-VirtualSwitch -VMHost $esx).Name -contains "vSwitch0" -and $($(Get-VMHost -Name $esx).ExtensionData.Config.Network.Vnic).Portgroup -like $managementPortgroup) {
#        #$frag8 = getSwitchConf -vSwitch vSwitch0 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch0</h4>" | Out-String
#        $content += getSwitchConf -vSwitch vSwitch0 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch0</h4>" | Out-String
#    } else {
#        #$frag8 = ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch0</h4>" | Out-String
#        $content += ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch0</h4>" | Out-String
#    }
#    if ($(Get-VirtualSwitch -VMHost $esx).Name -contains "vSwitch1" -and $($(Get-VMHost -Name $esx).ExtensionData.Config.Network.Vnic).Portgroup -like $vMotionPortgroup) {
#        #$frag9 = getSwitchConf -vSwitch vSwitch1 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch1</h4>" | Out-String
#        $content += getSwitchConf -vSwitch vSwitch1 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch1</h4>" | Out-String
#    } else {
#        #$frag9 = ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch1</h4>" | Out-String
#        $content += ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch1</h4>" | Out-String
#    }
#    if ($(Get-VirtualSwitch -VMHost $esx).Name -contains "vSwitch2") {
#        #$frag10 = getSwitchConf -vSwitch vSwitch2 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch2</h4>" | Out-String
#        $content += getSwitchConf -vSwitch vSwitch2 -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch2</h4>" | Out-String
#    } else {
#        #$frag10 = ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch2</h4>" | Out-String
#        $content += ConvertTo-Html -As List -Fragment -PreContent "<h4>vSwitch2</h4>" | Out-String
#    }
    foreach ($vSwitch in Get-VirtualSwitch -VMHost $esx) {
        #if ($(Get-VirtualPortGroup -VirtualSwitch $vSwitch) -like $managementPortgroup) {
        if ($(Get-VirtualPortGroup -VirtualSwitch $vSwitch).Name -eq $(Get-VMHostNetworkAdapter -VMHost $esx -VMKernel | where {$_.ManagementTrafficEnabled -eq $True} | select PortGroupName).PortGroupName) {
            $content += getSwitchConf -vSwitch $vSwitch -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>$vSwitch</h4>" | Out-String
        #} elseif ($(Get-VirtualPortGroup -VirtualSwitch $vSwitch) -like $vMotionPortgroup) {
        } elseif ($(Get-VirtualPortGroup -VirtualSwitch $vSwitch).Name -eq $(Get-VMHostNetworkAdapter -VMHost $esx -VMKernel | where {$_.VMotionEnabled -eq $True} | select PortGroupName).PortGroupName) {
            $content += getSwitchConf -vSwitch $vSwitch -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>$vSwitch</h4>" | Out-String
        } else {
            $content += getSwitchConf -vSwitch $vSwitch -vHost $esx | ConvertTo-Html -As List -Fragment -PreContent "<h4>$vSwitch</h4>" | Out-String
        }
     }

    $colorTagTable = @{OK = ' bgcolor="#00ff00">';
                    Wrong = ' bgcolor="#ff0000">'}
    #$frags = @($frag50,$frag5,$frag6,$frag7,$frag8)
    #$newFrags += @()
    #$content += @()
    $colorTagTable.Keys | foreach {$content = $content -replace ">$_ ",($colorTagTable.$_)}

    #foreach ($frag in $frags){
        #$colorTagTable.Keys | foreach {$frag = $frag -replace ">$_ ",($colorTagTable.$_)}
        #$newFrags += $frag
    #}
    $body += "<a href=`"#$($esx.Name)`">$($esx.Name)</a><br>"
}

$head = "<style>"
$head += "body { background-color:#dddddd; font-family:Tahoma; font-size:12pt; }"
$head += "td, th { border:1px solid black; border-collapse:collapse; }"
$head += "th { color:white; background-color:black; }"
$head += "table, tr, td, th { padding: 2px; margin: 0px }"
$head += "table { margin-left:50px; }"
$head += "</style>"

#ConvertTo-Html -Head $head -Body "<h1>$($vCenter)</h1>$body" -PostContent $newFrags > C:\tmp\$($vCenter).htm
ConvertTo-Html -Head $head -Body "<h1>$($vCenter)</h1>$body" -PostContent $content > $outFile
Disconnect-VIServer -Confirm:$false