<powershell>

$Path = $env:TEMP;
$Installer = "chrome_installer.exe";
Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/$Installer" -OutFile $Path\$Installer;
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
Remove-Item $Path\$Installer

$url = "https://symphony-software-catalog.s3.amazonaws.com/Agent/Windows/redcloak.msi"
$output = "C:\Windows\Temp\redcloak.msi"
Invoke-WebRequest -Uri $url -OutFile $output
msiexec /i C:\Windows\Temp\redcloak.msi /quiet /qn

$parameters = @{
        Uri = 'https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/AmazonCloudWatchAgent.zip'
        OutFile = "$env:TEMP\AmazonCloudWatchAgent.zip"
}
Invoke-WebRequest @parameters

Expand-Archive -Path "$env:TEMP\AmazonCloudWatchAgent.zip" -DestinationPath "$env:TEMP\AmazonCloudWatchAgent"

Set-Location -Path "$env:TEMP\AmazonCloudWatchAgent"
.\install.ps1

$parameters = @{
        Uri = 'https://symphony-software-catalog.s3.amazonaws.com/Agent/Windows/CloudWatch/Windows+config.json'
        OutFile = "C:\Program Files\Amazon\AmazonCloudWatchAgent\config.json"
}
Invoke-WebRequest @parameters

Set-Location -Path 'C:\Program Files\Amazon\AmazonCloudWatchAgent\'
.\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:'C:\Program Files\Amazon\AmazonCloudWatchAgent\config.json' -s


$join_to_ad ="${join_to_ad}"
if("$join_to_ad" -eq "true"){
   New-Item -path C:\Temp\ -Name joinme_ad.txt -Value 'Joing me to ad' -Force
   $parameters = @{
        Uri = 'https://symphony-software-catalog.s3.amazonaws.com/Agent/AD_Join/join_windows_to_ad.ps1'
        OutFile = "C:\Temp\join_windows_to_ad.ps1"
   }
   Invoke-WebRequest @parameters
   $command = "C:\Temp\join_windows_to_ad.ps1"
   Invoke-Expression $command
   New-Item -path C:\Temp\ -Name join_windows_to_ad.ps1 -Value 'NULL' -Force
} else {
   New-Item -path C:\Temp\ -Name joinme_ad.txt -Value 'NO need to add to AD' -Force
}
refreshenv

</powershell>
