<powershell>
[Environment]::SetEnvironmentVariable("ECS_ENABLE_CPU_UNBOUNDED_WINDOWS_WORKAROUND", "true", "Machine")
[Environment]::SetEnvironmentVariable("ECS_DISABLE_METRICS", "false", "Machine")
Import-Module ECSTools
Initialize-ECSAgent -Cluster ${ecs_cluster}  -EnableTaskIAMRole

Set-ExecutionPolicy Bypass -Force;
#iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
#choco install python3 -y;

#$url = "http://jenkins-awsops-prod.sym-adv.com:8000/redcloak.msi"
#$output = "C:\Windows\Temp\redcloak.msi"

#Invoke-WebRequest -Uri $url -OutFile $output

#msiexec /i C:\Windows\Temp\redcloak.msi /quiet /qn

refreshenv

</powershell>
