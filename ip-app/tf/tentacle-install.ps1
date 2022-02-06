cd "C:\Program Files\Octopus Deploy\Tentacle"

# 172.16.10.0/24

.\Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console
.\Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
.\Tentacle.exe configure --instance "Tentacle" --reset-trust --console
.\Tentacle.exe configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console
.\Tentacle.exe configure --instance "Tentacle" --trust "YOUR_OCTOPUS_THUMBPRINT" --console
.\"netsh" advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
.\Tentacle.exe register-with --instance "Tentacle" --server "http://YOUR_OCTOPUS" --apiKey="API-YOUR_API_KEY" --role "server" --environment "Staging" --comms-style TentaclePassive --console
.\Tentacle.exe service --instance "Tentacle" --install --start --console
