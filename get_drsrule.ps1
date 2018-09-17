Connect-VIServer -Server $vCenter

Get-DrsRule -Cluster $(Get-Cluster -Name "Cluster") | Select-Object Cluster,Name,KeepTogether,Enabled, @{N="VMnames";E={ $_.VMIDs|%{(get-view -id $_).name}}}