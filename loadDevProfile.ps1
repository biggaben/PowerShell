<#
    Program Name: PowerProfile
    Author: David Holmertz
    Created Date: January 16, 2024
    Copyright (c) 2024 David Holmertz. All rights reserved.

    Description:
    PowerProfile is a custom PowerShell script designed to enhance the PowerShell experience. It includes functionalities like SniffSearch for advanced searching with custom tree depth, prompt restyling, GitHub shortcuts, and Path recording with go-back functionality. These features aim to streamline and optimize the usage of PowerShell for various common and advanced tasks.
   
    Contribution:
    If you wish to contribute to this project or have any suggestions or bug reports, please feel free to open an issue or a pull request on GitHub at https://github.com/BigGaben. Contributions are welcomed and appreciated.

    License:
    This script is for personal use. Redistribution or modification without explicit permission is prohibited.
#>

<#
.SYNOPSIS
Developer's PowerShell profile

.DESCRIPTION
As Default profile but with an addition of custom aliases and functions for development.

.EXAMPLE
To use this profile, copy it to your PowerShell profile directory. The default location for this directory is:
C:\Users\username\Documents\WindowsPowerShell\Microsoft.Developer_profile.ps1

.NOTES
This profile are manually loaded once in terminal. To reload it after editing, run the following command:
. C:\Users\$env:USERNAME\Documents\Microsoft.Developer_profile.ps1
#>

# Define the source and destination files
# User profile
$sourceFile = "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
# Developer profile
$destinationFile = "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.Developer_profile.ps1"

# Define the header for the developer profile
$devFileHeader = @"
##############################################################################################


# Developer's PowerShell profile

# As Default profile but with an addition of custom aliases and functions for development.

# To use this profile, copy it to your PowerShell profile directory. The default location for this directory is:
# C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Microsoft.Developer_profile.ps1

# This profile are manually loaded once in terminal. To reload it after editing, run the following command:
# . C:\Users\$env:USERNAME\Documents\Microsoft.Developer_profile.ps1

"@

# Read the content of the source file
$content = Get-Content $sourceFile
$devContent = @"
### DEVELOPER

function LoadDevProfile {
  . 'C:\Users\`$env:USERNAME\Documents\PowerShell\loadDevProfile.ps1'
}

Set-Alias loaddev       LoadDevProfile # Load the Developer profile

##############################################################################################
"@

# Clear and Write the content to the destination file, replacing its current content
Clear-Content $destinationFile
Set-Content -Path $destinationFile -Value $devFileHeader -Force
Add-Content -Path $destinationFile -Value $content 
Add-Content -Path $destinationFile -Value $devContent

# Replace specific lines in the content
<# $content = $content -replace 'line to be replaced', 'replacement line' #>

# Add additional lines to the destination file
<# Add-Content -Path $destinationFile -Value "Additional line 1"
Add-Content -Path $destinationFile -Value "Additional line 2" #>

Write-Host "Development Profile Updated.`nLoading Developer_profile."

powershell -noexit "& ""C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.Developer_profile.ps1"""  # Load this profile and keep the terminal open
