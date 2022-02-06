
## Configure winrm to allow unencrypted connections
## winrm get winrm/config/service
## netsh advfirewall firewall add rule name="WinRM Access" dir=in action=allow protocol=TCP localport=5985
New-NetFirewallRule -DisplayName "WinRM Access" -Direction inbound -Profile Any -Action Allow -LocalPort 5985 -Protocol TCP
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted=\"true\"}'

curl -o C:\tentacle.msi https://octopus.com/downloads/latest/WindowsX64/OctopusTentacle
msiexec /i C:\tentacle.msi /quiet

