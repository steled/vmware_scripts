# Change variables
$vmHostName = "Hostname"
$workDir = "C:\tmp\"
# Standard configuration
$stdConf = $workDir + "hostname_advSet_std.txt"
# Configuration of new host
$actConf = $workDir + "hostname_advSet_act.txt"
# differences between standard configuration and new host configuration
$chgConf = $workDir + "hostname_advSet_chg.txt"

# Get all Advanced Settings with Name & Value from new host and save settings at $actConf
Get-AdvancedSetting -Entity (Get-VMHost -Name $vmHostName) | Format-Table -Property Name, Value | Out-File -FilePath $actConf
# Compare standard settings ($stdConf) by settings from new host ($actConf) and save differences at new file ($chgConf)
Compare-Object -ReferenceObject $((Get-Content $stdConf) -replace "\s+", ";") -DifferenceObject $((Get-Content $actConf) -replace "\s+", ";") | Where-Object {$_.SideIndicator -eq "<="} | Select-Object -ExpandProperty InputObject | Add-Content $chgConf
# Import different settings from file ($chgConf)
$csv = Import-Csv $chgConf -Header "Name","Value" -Delimiter ";"
# Set standard settings for new host
$csv | ForEach-Object { Get-AdvancedSetting -Entity (Get-VMHost -Name $vmHostName) -Name $_.Name | Set-AdvancedSetting -Value $_.Value -Confirm:$false}
