<powershell>

Set-ExecutionPolicy Bypass -Force;
Set-DnsClientServerAddress -interfacealias Ethernet* -serveraddresses ("${dns1}")

</powershell>
