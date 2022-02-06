Add-Type -Path 'Newtonsoft.Json.dll'
Add-Type -Path 'Octopus.Client.dll'

$octopusApiKey = 'API-ABCXYZ'
$octopusURI = 'http://YOUR_OCTOPUS'

$endpoint = new-object Octopus.Client.OctopusServerEndpoint $octopusURI, $octopusApiKey
$repository = new-object Octopus.Client.OctopusRepository $endpoint

$tentacle = New-Object Octopus.Client.Model.MachineResource

$tentacle.name = "Tentacle registered from client"
$tentacle.EnvironmentIds.Add("Environments-1")
$tentacle.Roles.Add("WebServer")

$tentacleEndpoint = New-Object Octopus.Client.Model.Endpoints.ListeningTentacleEndpointResource
$tentacle.EndPoint = $tentacleEndpoint
$tentacle.Endpoint.Uri = "https://YOUR_TENTACLE:10933"
$tentacle.Endpoint.Thumbprint = "YOUR_TENTACLE_THUMBPRINT"

$repository.machines.create($tentacle)
