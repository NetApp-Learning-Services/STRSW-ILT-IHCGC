Import-Module NetApp.ONTAP
$password = ConvertTo-SecureString "Netapp1!" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "admin",$password
Connect-NcController 192.168.0.101 -Credential $cred
Get-NcAggr