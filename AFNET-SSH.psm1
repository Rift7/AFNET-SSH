# Define the module name and its properties
#$ModuleName = "AFNET-SSH"
#$ModuleVersion = "1.0.0"
#$ModuleAuthor = "Joshua Hedge"

# Define the module functions

# Function to connect to an SSH server
function Connect-SSH {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Server,
        
        [Parameter(Mandatory=$true)]
        [string]$Username,
        
        [Parameter(Mandatory=$true)]
        [string]$Password,
        
        [bool]$AcceptFingerprint = $false
    )
    
    # Create a TcpClient object to connect to the SSH server
    $TcpClient = New-Object System.Net.Sockets.TcpClient($Server, 22)
    
    # Create a StreamReader object to read the output from the SSH server
    $StreamReader = New-Object System.IO.StreamReader($TcpClient.GetStream())
    
    # Create a StreamWriter object to send commands to the SSH server
    $StreamWriter = New-Object System.IO.StreamWriter($TcpClient.GetStream())
    
    # Read the banner message from the SSH server
    $Banner = $StreamReader.ReadLine()
    
    # If the banner message contains the SSH fingerprint prompt, send the fingerprint and read the next banner message
    if ($Banner.StartsWith("The authenticity of host") -and $AcceptFingerprint) {
        $StreamWriter.WriteLine("yes")
        $StreamWriter.Flush()
        $Banner = $StreamReader.ReadLine()
    }
    
    # Send the username and read the password prompt
    $StreamWriter.WriteLine($Username)
    $StreamWriter.Flush()
    $Banner = $StreamReader.ReadLine()
    
    # Send the password and read the next banner message
    $StreamWriter.WriteLine($Password)
    $StreamWriter.Flush()
    $Banner = $StreamReader.ReadLine()
    
    # Check if the login was successful
    if ($Banner -notmatch "Welcome") {
        Write-Error "Login failed"
        return $null
    }
    
    # Create a session object to store the TcpClient and StreamReader/StreamWriter objects
    $Session = New-Object -TypeName PSObject -Property @{
        TcpClient = $TcpClient
        StreamReader = $StreamReader
        StreamWriter = $StreamWriter
    }
    
    return $Session
}

# Function to send a command over an SSH session and return the output
function Send-SSHCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,
        
        [Parameter(Mandatory=$true)]
        [psobject]$Session
    )
    
    # Send the command and read the output
    $Session.StreamWriter.WriteLine($Command)
    $Session.StreamWriter.Flush()
    $Output = ""
    while ($true) {
        $Line = $Session.StreamReader.ReadLine()
        if ($Line -eq $null) { break }
        if ($Line.Trim() -eq "") { continue }
        if ($Line.Trim() -eq $Command) { continue }
        $Output += "$Line`r`n"
        if ($Line.Contains("#")) { break }
    }
    
    return $Output
}

<#>
function Send-SSHCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Net.Sockets.TcpClient] $TcpClient,

        [Parameter(Mandatory = $true)]
        [string] $Command,

        [Parameter()]
        [switch] $Quiet
    )

    $Stream = $TcpClient.GetStream()

    # Clear the stream buffer
    $null = $Stream.Read($null, 0, $Stream.Length)

    # Send the command
    [byte[]]$CommandBytes = [System.Text.Encoding]::ASCII.GetBytes("$Command`r")
    $Stream.Write($CommandBytes, 0, $CommandBytes.Length)

    # Wait for the command prompt
    $Prompt = $TcpClientPrompt
    while (-not $Stream.DataAvailable -or $Stream.ReadTimeout -gt 0) {
        $ReadBuffer = New-Object byte[] 4096
        $Stream.ReadTimeout = 1000
        $BytesRead = $Stream.Read($ReadBuffer, 0, $ReadBuffer.Length)
        $Response = [System.Text.Encoding]::ASCII.GetString($ReadBuffer, 0, $BytesRead)
        if ($Response.Contains($Prompt)) {
            break
        }
    }

    # Discard the banner if there is one
    if ($Response.StartsWith($Banner)) {
        $Response = $Response.Substring($Banner.Length)
    }

    # Capture the command output
    $Output = ""
    while ($Stream.DataAvailable -or $Stream.ReadTimeout -gt 0) {
        $ReadBuffer = New-Object byte[] 4096
        $Stream.ReadTimeout = 1000
        $BytesRead = $Stream.Read($ReadBuffer, 0, $ReadBuffer.Length)
        $Output += [System.Text.Encoding]::ASCII.GetString($ReadBuffer, 0, $BytesRead)
    }

    # Remove trailing newlines from the output
    $Output = $Output.TrimEnd("`r`n")

    # Write the output to the console and optionally to a file
    Write-Output $Output
    if (-not $Quiet -and $Output) {
        Add-Content -Path $LogFile -Value $Output
    }
}
#>

# Function to disconnect an SSH session
function Disconnect-SSH {
    param(
        [Parameter(Mandatory=$true)]
        [psobject]$Session
    )
    
    # Close the TcpClient and StreamReader/StreamWriter objects
    $Session.StreamWriter.Close()
    $Session.StreamReader.Close()
    $Session.TcpClient.Close()
}
