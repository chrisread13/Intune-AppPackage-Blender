<#
.SYNOPSIS
    Uninstall Blender
.DESCRIPTION
    Uninstall Blender specifically for the University of South Florida
    Version 2.83
.EXAMPLE
    PS C:\> Uninstall-Blender.ps1
    Uninstalls Blender
.NOTES
.RELEASENOTES
    v1.0 Initial release
#>

# Function to log events in the IntuneMagenemtExtension.log and to create an addition app-specific log file.
function Set-IntuneAppLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LogMessage,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LogComponent = "DE-Script"
    )
    process {
        $IntuneLogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log" # Path of "active" IntuneManagementExtension log
        $TimeGenerated = "$(Get-Date -Format HH:mm:ss.fff+000)" # Gathers specific timestamp formatted for SCCM style logs
        $LineFormat = @"
<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="1" thread="314" file="">
"@
        $LineValues = "[DE-Script] $LogMessage", $TimeGenerated, (Get-Date -Format MM-dd-yyyy), $LogComponent # Sets array of values to be splatted into log output below
        $LogOutput = $LineFormat -f $LineValues # Uses String formatting to create the string
        # reference: https://devblogs.microsoft.com/scripting/understanding-powershell-and-basic-string-formatting/

        # Check for App specific log file
        if ($FileExplorerFriendlyName) { $ProgramName = $FileExplorerFriendlyName } 
        $AppSpecificLogPath = Join-Path -Path (Split-Path -Path $IntuneLogPath -Parent) -ChildPath ("$ProgramName-$ProgramVersion.log") # Create name for app specific log file

        # Writes to IntuneManagementExtension Log
        Add-Content -Value $LogOutput -Path $IntuneLogPath, $AppSpecificLogPath  # Write to IntuneManagementExtension.log and the app specific log file
        # Writes to console when testing in CMD
        Write-Output $LogMessage
    }
}

# Uninstallation arguments as a string literal
$UninstallArguments = @" 
/x blender.msi /qn
"@

$CurrentDirectory = $PSScriptRoot
#$InstallationDirectory = ""
#$ExecutableName = ""
$msiexecPath = "C:\Windows\System32\msiexec.exe"

# Set-IntuneAppLog specific variables
$ProgramName = "Blender"
# $FileExplorerFriendlyName = "NotepadPlusPlus" # Uncomment if the application name contains a reserved chracter in the name
# Reference: https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file#naming-conventions
$ProgramVersion = "2.83"
$ScriptName = (Split-path -Path $PSCommandPath -Leaf) # Gets the name of the PS1 file being run. This is used in the Component column in logging

# Uninstall
try {
    Start-Process -FilePath $MsiexecPath -WorkingDirectory $currentDirectory -ArgumentList $uninstallArguments -Wait
    #Start-Process -FilePath $ExecutableName -Verbose -WorkingDirectory $CurrentDirectory -ArgumentList $UninstallArguments -Wait
    #Start-Process -FilePath $ExecutableName -Verbose -WorkingDirectory $InstallationDirectory -ArgumentList $UninstallArguments -Wait
    Write-Output "Uninstallation Successful"
    Set-IntuneAppLog -LogMessage "Uninstallated $ProgramName Successfully" -LogComponent $ScriptName
    exit 0 # Expected result of successful uninstallation
}
catch {
    # Print error logic sourced from <https://www.leaseweb.com/labs/2014/01/print-full-exception-powershell-trycatch-block-using-format-list/>
    Write-Error "There was an error during uninstallation.`nErrorTpe:`t$_.Exception.GetType().Fullname`nError:`t$_.Exception.Message"
    Set-IntuneAppLog -LogMessage "{ERROR} There was an error during the uninstallation of $ProgramName." -LogComponent $ScriptName
    exit -1 # General error
}
