$vcenter = "<vcenter"
$user = "<user>"
$password = "<password>"

Connect-VIServer -Server $vcenter -User $user -Password $password

$result = foreach($vm in Get-VM) {
    $obj = New-Object PSObject -Property @{ Name = $vm.name }
    foreach($cfield in ((get-vm -Name $vm).CustomFields)) {
        $obj | Add-Member -MemberType NoteProperty -Name $cfield.Key -Value $cfield.Value
    }
    $obj
}
$result | Format-Table -AutoSize

Disconnect-VIServer -Server $vcenter -Confirm:$false -Force