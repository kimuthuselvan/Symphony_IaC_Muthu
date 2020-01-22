<powershell>

$url = "http://jenkins-awsops-prod.sym-adv.com:8000/redcloak.msi"
$output = "C:\Windows\Temp\redcloak.msi"

Invoke-WebRequest -Uri $url -OutFile $output

msiexec /i C:\Windows\Temp\redcloak.msi /quiet /qn

refreshenv

</powershell>
