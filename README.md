# AFNET-SSH
AFNET-SSH is a PowerShell module for automating SSH connections to switches, servers, etc., including those on the NIPR and SIPR networks. It also supports automatic SSH fingerprint acceptance and password authentication.

Are you tired of having to use clunky or expensive software just to automate your SSH scripts on NIPR or SIPR? Look no further than AFNET-SSH!

That's right, AFNET-SSH is one of the few "free" options out there for automated scripting with SSH, it's built right into PowerShell so you don't have to worry about things like "Licensing" or "Approved Software Lists". Unlike other SSH automation tools that may require approval from ISSM or AFCEDS, AFNET-SSH is not officially supported or endorsed by any particular organization or agency.

## Features
* Open SSH tunnels with ease using System.Net.Sockets.TcpClient
* Optional automatic SSH fingerprint acceptance (because who has time for manual verification?)
* Automatic login with username and password
* Send commands over SSH and print output to console
## Installation
* Download the AFNET-SSH folder and save it to your PowerShell module directory ($env:PSModulePath).
* Open a new PowerShell session and run `Import-Module AFNET-SSH`.
## Usage

To open an SSH tunnel and send commands, use the `Connect-SSH` function. Here's an example:

powershell

`Connect-SSH -Server 192.168.0.1 -Username admin -Password p@ssw0rd`

This will open an SSH connection to 192.168.0.1 with the specified username and password. You can then send commands using the `Send-SSHCommand` function:

powershell

`Send-SSHCommand -Command 'ls -la' -Session $Session`

This will send the `ls -la` command to the SSH session `$Session` and print the output to the console.

## Examples

```# Connect to the SSH server
$Session = Connect-SSH -Server 192.168.0.1 -Username admin -Password p@ssw0rd

# Define an array of commands to send
$Commands = @(
    "show interfaces status",
    "show mac address-table",
    "show running-config"
)

# Loop through each command and write the output to a file
foreach ($Command in $Commands) {
    # Send the command and capture the output
    $Output = Send-SSHCommand -Command $Command -Session $Session
    
    # Write the output to a file
    $Filename = "_$Command.txt"
    $Output | Out-File $Filename
    
    # Optionally, print the output to the console as well
    Write-Output $Output
}

# Close the SSH session
Disconnect-SSH -Session $Session
```

## Disclaimer

And that's it! AFNET-SSH makes it easy to automate your SSH scripts without having to worry about software approvals or clunky interfaces.

Please note that while AFNET-SSH is not explicitly on the "approved software list", it is still important to exercise caution when using it on government networks. Use at your own risk.

## License
AFNET-SSH is released under the MIT License.
