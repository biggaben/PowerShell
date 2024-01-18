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
$sourceFile = "C:\Users\david\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
# Developer profile
$destinationFile = "C:\Users\david\Documents\PowerShell\Microsoft.Developer_profile.ps1"

# Read the content of the source file
$content = Get-Content $sourceFile

# Write the content to the destination file, replacing its current content
Set-Content -Path $destinationFile -Value $content

# Replace specific lines in the content
$content = $content -replace 'line to be replaced', 'replacement line'

# Add additional lines to the destination file
Add-Content -Path $destinationFile -Value "Additional line 1"
Add-Content -Path $destinationFile -Value "Additional line 2"

Write-Host "Development Profile Updated.`n"

powershell -noexit "& ""C:\Users\$env:USERNAME\Documents\PowerShell\Developer_profile.ps1"""  # Load this profile and keep the terminal open