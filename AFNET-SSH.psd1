@{
    ModuleVersion = '1.0.0.0'
    RootModule = 'AFNET-SSH.psm1'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    Author = 'Joshua Hedge'
    CompanyName = 'Rift7'
    Description = 'A PowerShell module for automating SSH connections and commands'
    PrivateData = @{
        PSData = @{
            ProjectUri = 'https://github.com/Rift7/AFNET-SSH'
            LicenseUri = 'https://github.com/Rift7/AFNET-SSH/blob/master/LICENSE'
            ReleaseNotes = 'Dev release of AFNET-SSH module.'
        }
    }
    RequiredModules = @()
    FunctionsToExport = @('Connect-SSH', 'Send-SSHCommand', 'Disconnect-SSH')
}
