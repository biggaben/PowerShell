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

# Define the source and destination directories
$sourceDir = "C:\Users\$env:USERNAME\Documents\PowerShell\"
$destinationDir = "C:\Users\$env:USERNAME\Dropbox\Code\PowerShell\"

# Get all files in the source directory and copy them to the destination directory
Get-ChildItem -Path $sourceDir -File | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $destinationDir -Force
}

# Define the source and destination directories
$sourceDir = "C:\Users\$env:USERNAME\Documents\PowerShell\CommandLists\"
$destinationDir = "C:\Users\$env:USERNAME\Dropbox\Code\PowerShell\"

# Get all files in the source directory and copy them to the destination directory
Get-ChildItem -Path $sourceDir -File | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $destinationDir -Force
}

Write-Host "Local Profile Updated.`n"