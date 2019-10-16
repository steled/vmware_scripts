# https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.vcenterhost.doc/GUID-621BC36D-D077-4AE2-9604-42791057AFAF.html
# https://pubs.vmware.com/vsphere-51/index.jsp?topic=%2Fcom.vmware.powercli.cmdletref.doc%2FNew-CustomAttribute.html
New-CustomAttribute -Name "<ATTRIBUTE>" -TargetType VirtualMachine
# https://pubs.vmware.com/vsphere-51/index.jsp?topic=%2Fcom.vmware.powercli.cmdletref.doc%2FGet-Annotation.html
get-vm -Name "<VM-NAME>" | Get-Annotation -CustomAttribute "<ATTRIBUTE>"
# https://pubs.vmware.com/vsphere-51/index.jsp?topic=%2Fcom.vmware.powercli.cmdletref.doc%2FSet-Annotation.html
get-vm -Name "<VM-NAME>" | set-Annotation -CustomAttribute "<ATTRIBUTE>" -Value "<ATTRIBUTE_VALUE>" -WhatIf

$vcenter = "<vcenter>"
$file = "<file>"

Connect-VIServer -Server $vcenter

$csv = Import-Csv $file -Header Name, env, cid -Delimiter ";"

get-vm | Get-Annotation -CustomAttribute "cid" | Sort-Object -Property "AnnotatedEntity" | Format-Table -AutoSize
get-vm | Get-Annotation -CustomAttribute "env" | Sort-Object -Property "AnnotatedEntity" | Format-Table -AutoSize


foreach ($vm in $csv) {
    $name = $($vm.Name)
    $env = $($vm.env)
    $cid = $($vm.cid)
    #Write-Host $systemname $cid $environment
    if (get-vm | Where-Object {$_.Name -eq $name}) {
        get-vm -Name $name | set-Annotation -CustomAttribute "cid" -Value $cid
        get-vm -Name $name | set-Annotation -CustomAttribute "env" -Value $env
    } else {
        write-host $name
    }
}