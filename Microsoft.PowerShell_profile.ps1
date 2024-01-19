<#
.SYNOPSIS
    PowerProfile is a custom PowerShell script designed to enhance the PowerShell experience.

.DESCRIPTION
    PowerProfile is a custom PowerShell script designed to enhance the PowerShell experience. It includes functionalities like SniffSearch for advanced searching with custom tree depth, prompt restyling, GitHub shortcuts, and Path recording with go-back functionality. These features aim to streamline and optimize the usage of PowerShell for various common and advanced tasks.

.NOTES
    Program Name: PowerProfile
    Author: David Holmertz
    Created Date: January 16, 2024
    Copyright (c) 2024 David Holmertz. All rights reserved.
    License: This script is for personal use. Redistribution or modification without explicit permission is prohibited.

.LINK
    GitHub Repository: https://github.com/BigGaben

.FUNCTIONALITY
    - ReloadProfile: Reloads the PowerShell profile.
    - prompt: Customizes the PowerShell prompt with various information like time, uptime, user, IP, current folder, Git branch, and more.
    - ResetPrompt: Resets the PowerShell prompt to the default format.
    - SniffSearch: Performs advanced searching in the current directory with custom tree depth and search string.
    - CondaListShortcuts: Lists Conda commands shortcuts from a text file.
    - CondaCreateEnv: Creates a Conda environment with the specified name and optional Python version.
    - CondaUpdateEnv: Updates a Conda environment with the specified name or all environments.
    - CondaRemoveEnv: Removes a Conda environment with the specified name.
    - LaunchAdminPS: Launches an elevated PowerShell session in the current directory.
    - LaunchDebloater: Launches a PowerShell script to debloat Windows.
    - CreateDirectoryIfNotExists: Creates a directory if it does not exist and changes to it.
    - TwoDirUp: Changes the current directory to two levels up.
    - ThreeDirUp: Changes the current directory to three levels up.
    - ToRootDir: Changes the current directory to the root directory.
    - EditPrompt: Returns the default PowerShell prompt format.
    - EditProfileInCode: Opens the PowerShell profile and custom commands file in Visual Studio Code.
    - UpdateDevProfile: Updates the development profile.
    - gitStatus: Displays the Git repository status.
    - gitAdd: Adds changes to the Git repository.
    - gitAddAll: Adds all changes to the Git repository.
    - gitBranch: Displays the Git branch.
    - gitBranchAll: Displays all Git branches.
    - gitBranchDelete: Deletes a Git branch.
    - gitCommit: Commits changes to the Git repository.
    - gitCommitAll: Commits all changes to the Git repository.
    - gitCheckoutBranch: Creates and checks out a new Git branch.
    - gitConfigList: Lists Git configuration settings.
    - gitClone: Clones a Git repository.
    - gitClean: Cleans the Git repository by removing untracked files and directories.
    - gitCheckoutMaster: Checks out the master branch in the Git repository.
    - gitCheckout: Checks out a branch in the Git repository.
    - gitCherryPickAbort: Aborts the current cherry-pick operation in the Git repository.
    - LoadScript: Loads a PowerShell script into the current session.
    - SearchCustomCommand: Searches for a custom command in the custom commands file.
    - ShowCommandList: Displays a list of available commands from the custom commands file.
    - RecordPath: Records the current path with an optional name for easy navigation.
#>
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

function ReloadProfile {
    <#
    .SYNOPSIS
        Reloads the PowerShell profile.
    #>
    . $PROFILE # This profile is run once when PowerShell starts up.
}

##### Initialization #####
$ip = Invoke-RestMethod http://ipinfo.io/json

##### Prompts #####


<#
.SYNOPSIS
    Customizes the PowerShell prompt with various information like time, uptime, user, IP, current folder, Git branch, and more.

.DESCRIPTION
    This function customizes the PowerShell prompt by displaying various information such as the current time, system uptime, current user, public IP address, computer name, current folder, parent folder, elevated indicator, and Git repository information. The prompt string is constructed using different colors and formatting codes for better visibility and readability.

.NOTES
    - This function requires the 'Get-Uptime' cmdlet to be available.
    - Git commands are used to retrieve the current Git branch and status. If Git is not installed or there is an error executing Git commands, the Git information will not be displayed.

.EXAMPLE
    PS C:\Users\David\Documents> prompt
    [15:30:45][Uptime: 01.10:25:15][User: David@192.168.1.100] [ADMIN] {Documents} [Git: main]
    =>

.OUTPUTS
    System.String

#>
function prompt {
    # Time
    $currentTime = Get-Date -Format "HH:mm:ss"
    $uptime = (Get-Uptime).ToString("dd\.hh\:mm\:ss")
    $currentTimeString = "`e[48;5;0m`e[38;5;15m$currentTime`e[0m"
    $currentuser = $(whoami)
    $uptime = "`e[38;5;11m$uptime`e[0m"
    $currentuser =  "`e[38;5;9m$currentuser`e[0m"
    $publicIP = "`e[38;5;3m$($ip.ip)`e[0m"
    $computername = "`e[38;5;9m$($env:COMPUTERNAME)`e[0m"

    
    # Current Folder and Parent
    $currentLocation = Get-Location
    $parentPath = Split-Path $currentLocation -Parent
    $currentFolder = Split-Path $currentLocation -Leaf

    # Determine display path
    $displayPath = if ($parentPath -and $parentPath -ne 'C:\') {
        "..\$($parentPath | Split-Path -Leaf)\$currentFolder"
    } else {
        $currentLocation
    }

    # Elevated Indicator
    $isAdmin = if ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { "[ADMIN]" } else { "" }

    # Git Repository Information
    $gitBranch = ''
    $gitColor = ''
    if (Get-Command git -ErrorAction SilentlyContinue) {
        try {
            $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
            if ($gitBranch) {
                $gitStatus = git status --porcelain 2>$null
                if ($gitStatus) {
                    $gitColor = "`e[31m" # Red color for changes
                } else {
                    $gitColor = "`e[34m" # Blue color for no changes
                }
                $gitBranch = "$gitColor [Git: $gitBranch]`e[0m"
            }
        } catch {
            # If there's an error executing git commands, do nothing
        }
    }
    
    # Construct and return the prompt string
    $prompt = "[{0}][Uptime: {1}][User: {2}@{3}] {4} {5} {6}`n=> " -f $currentTimeString, $uptime, $currentuser, $publicIP, $isAdmin, $gitBranch, $displayPath
    $prompt
}

function ResetPrompt {
    param(
        [string]$prompt = "$PWD> "
    )
    $prompt = "$PWD> "
}

<#
.SYNOPSIS
Searches for directories and files based on a specified search string.

.DESCRIPTION
The SniffSearch function searches for directories and files in the current location or its subdirectories, based on a specified search string. It provides options to exclude folders or files from the search results.

.PARAMETER searchString
Specifies the search string to match against directory or file names.

.PARAMETER depth
Specifies the maximum depth of subdirectories to search. Default value is 0, which means only the current location is searched.

.PARAMETER noFolders
Switch parameter to exclude directories from the search results.

.PARAMETER noFiles
Switch parameter to exclude files from the search results.

.EXAMPLE
SniffSearch -searchString "test" -depth 2
Searches for directories and files with names containing "test" in the current location and its subdirectories up to a depth of 2.

.EXAMPLE
SniffSearch -searchString "script" -noFolders
Searches for files with names containing "script" in the current location and its subdirectories, excluding directories from the search results.

#>
function SniffSearch {
    param (
        [String]$searchString = $null,    # The search string to match against directory or file names
        [int]$depth = 0,                  # The maximum depth of subdirectories to search
        [switch]$noFolders = $null,       # Switch parameter to exclude directories from the search results
        [switch]$noFiles = $null          # Switch parameter to exclude files from the search results
    )

    $currentLocation = Get-Location

    # Function to filter and sort items
    function FilterAndSortItems {
        param (
            [Parameter(Mandatory)]
            [ValidateSet("Directory","File")]
            [string]$itemType    # The type of items to filter (Directory or File)
        )

        # Determine the type to filter
        $typeFilter = switch ($itemType) {
            "Directory" { [System.IO.DirectoryInfo] }
            "File" { [System.IO.FileInfo] }
        }

        # Get items and store them in a variable
        $items = Get-ChildItem -Path $currentLocation -Recurse -Depth $depth | Where-Object { $_ -is $typeFilter }

        if (-not [string]::IsNullOrWhiteSpace($searchString)) {
            $items = $items | Where-Object { $_ -is $typeFilter -and $_.Name -like $searchString }
        }

        Write-Host "Filtered $itemType :`n$($items.Name)"

        foreach ($item in $items) {
            Write-Host "`nFull name: $($item.Name)"
        }

        $sortedItems = $items | Sort-Object -Property Name | Select-Object -ExpandProperty Name

        $sortedItems | Out-GridView -PassThru -Title "Select items to sort" | Sort-Object -Property Name | Format-Table Name
    }

    # Search for Directories
    if (-not $noFolders) {
        Write-Host "Directories:"
        FilterAndSortItems -ItemType Directory
    }

    # Search for Files
    if (-not $noFiles) {
        Write-Host "Files:"
        FilterAndSortItems -ItemType File
    }
}

function CondaListShortcuts {
    param (
        [string]$pattern
    )
    $condaCommandsPath = "C:\Users\$env:USERNAME\Documents\PowerShell\CondaCommands.txt"
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        Get-Content $condaCommandsPath
    } else {
        Select-String -Path $condaCommandsPath -Pattern $pattern
    }
}

function CondaCreateEnv {
    param (
        [string]$envName,
        [string]$pythonVersion
    )
    if ([string]::IsNullOrWhiteSpace($pythonVersion)) {
        conda create -n $envName
    } else {
        conda create -n $envName python=$pythonVersion
    }
}

function CondaUpdateEnv {
    param (
        [string]$envName
    )
    if ([string]::IsNullOrWhiteSpace($envName)) {
        conda update --all
    } else {
        conda update --all -n $envName
    }
}

function CondaRemoveEnv { 
    param (
        [string]$envName
    ) 
        conda remove -n $envName --all 
}

<#
.SYNOPSIS
Launches a new instance of PowerShell with administrative privileges and sets the location to the current directory.

.DESCRIPTION
The LaunchAdminPS function launches a new instance of PowerShell with administrative privileges using the Start-Process cmdlet. It also sets the location of the new PowerShell session to the current directory.

.PARAMETER None

.EXAMPLE
LaunchAdminPS
This example demonstrates how to use the LaunchAdminPS function to launch a new instance of PowerShell with administrative privileges and set the location to the current directory.

#>
function LaunchAdminPS { 
    $currentLocation = (Get-Location).Path
    Start-Process "C:\Program Files\PowerShell\7\pwsh.exe" -Verb RunAs -ArgumentList "-NoExit", "-Command Set-Location -LiteralPath '$currentLocation'" 
}

<#
.SYNOPSIS
Launches the Debloater script.

.DESCRIPTION
This function launches the Debloater script by starting a new PowerShell process with elevated privileges and executing the script using the Invoke-Expression (iex) cmdlet.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
LaunchDebloater
Launches the Debloater script.

#>

function LaunchDebloater { 
    Start-Process PowerShell -ArgumentList "-Command `" iwr -useb https: christitus.com win | iex`"" -Verb RunAs 
}

<#
.SYNOPSIS
Creates a directory if it does not exist and changes the current location to the newly created directory.

.DESCRIPTION
The CreateDirectoryIfNotExists function checks if a directory exists at the specified path. If the directory does not exist, it prompts the user to create it. If the user chooses to create the directory, it creates the directory and changes the current location to the newly created directory. If the directory already exists, it simply changes the current location to the existing directory.

.PARAMETER dirName
The name of the directory to be checked and created if necessary.

.EXAMPLE
CreateDirectoryIfNotExists -dirName "C:\Temp"
This example checks if the directory "C:\Temp" exists. If it does not exist, it prompts the user to create it. If the user chooses to create the directory, it creates the directory and changes the current location to "C:\Temp". If the directory already exists, it changes the current location to "C:\Temp".

#>
function CreateDirectoryIfNotExists {
    param(
        [string]$dirName
    ) 
    if (!(Test-Path $dirName)) {
        $create = Read-Host "Directory '$dirName' does not exist. Do you want to create it? (y N)" 
        if ($create -eq 'y') {
            New-Item -ItemType Directory -Path $PWD -Name $dirName | Out-Null 
        } 
    }
    Set-Location $dirName
}

function TwoDirUp {
    Set-Location ..\..\..
}

function ThreeDirUp {
    Set-Location ..\..\..\..
}


function ToRootDir {
    Set-Location ~\..\..\..
}

function EditPrompt {
    "$PWD> " 
}

function EditProfileInCode {
    code $PROFILE "C:\Users\$env:USERNAME\Documents\PowerShell\CustomCommands.txt"
}

function UpdateDevProfile {
    . 'C:\Users\david\Documents\PowerShell\update_dev_profile.ps1'
}

function gitStatus {
    git status
}

function gitAdd {
    git add
}

function gitAddAll {
    git add --all
}

function gitBranch {
    git branch
}

function gitBranchAll {
    git branch -a
}

function gitBranchDelete {
    git branch -d
}

function gitCommit {
    git commit
}

function gitCommitAll {
    git commit -a -m
}

function gitCheckoutBranch {
    git checkout -b
}

function gitConfigList {
    git config --list
}

function gitClone {
    git clone
}

function gitClean {
    git clean -fd
}

function gitCheckoutMaster {
    git checkout master
}

function gitCheckout {
    git checkout
}

function gitCherryPickAbort {
    git cherry-pick --abort
}

function gitCheckout {
    git checko
}

<#
.SYNOPSIS
    Loads a PowerShell script.

.DESCRIPTION
    This function creates a new profile and loads the specified PowerShell script.

.PARAMETER fileName
    The name of the script file to load.

.EXAMPLE
    LoadScript -fileName "MyScript.ps1"
#>
function LoadScript {
    param (
        [string]$fileName
    )

    $scriptPath = "C:\Users\$env:USERNAME\Documents\PowerShell\$fileName"

    # Create the new profile
    New-Item -Path $scriptPath -ItemType File -Force

    # Load the new profile
    . $newProfilePath
}

<#
.SYNOPSIS
    Searches for a custom command in a text file.

.DESCRIPTION
    This function searches for a custom command in a text file and returns the matching command.

.PARAMETER pattern
    The pattern to search for in the text file.

.EXAMPLE
    SearchCustomCommand -pattern "MyCommand"
#>
function SearchCustomCommand {
    param (
        [string]$pattern
    )
    $customCommandsPath = "C:\Users\$env:USERNAME\Documents\PowerShell\CustomCommands.txt"
    $content = Get-Content $customCommandsPath -Raw
    $matching = $content | Select-String -Pattern $pattern -AllMatches
    $matching.Matches.Value
}

<#
.SYNOPSIS
    Shows a list of commands.

.DESCRIPTION
    This function shows a list of commands based on the specified pattern. If no pattern is provided, it shows all commands.

.PARAMETER pattern
    The pattern to filter the command list.

.EXAMPLE
    ShowCommandList -pattern "MyCommand"
#>
function ShowCommandList {
    param (
        [string]$pattern
    )
    $customCommandsPath = "C:\Users\$env:USERNAME\Documents\PowerShell\CustomCommands.txt"
    
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        Get-Content $customCommandsPath
    } else {
        Select-String -Path $customCommandsPath -Pattern $pattern
    }
    
    GitListShortcuts $pattern
    CondaListShortcuts $pattern
    PowerShellListShortcuts $pattern
}

<#
.SYNOPSIS
    Records the current path.

.DESCRIPTION
    This function records the current path in a text file. If a name is provided, it records the path with the specified name.

.PARAMETER pattern
    The pattern to search for in the text file.

.PARAMETER name
    The name to associate with the recorded path.

.EXAMPLE
    RecordPath -name "MyPath"
#>
function RecordPath {
    param (
        [string]$pattern,
        [string]$name
    )
    $currentLocation = Get-Location
    $recordedPath = if ($name) {
        "$name : $($currentLocation.Path)"
    } else {
        $currentLocation.Path
    }
    $recordedPath | Out-File -FilePath "C:\Users\$env:USERNAME\Documents\PowerShell\RecordedPaths.txt" -Append
    Write-Host "Path '$currentLocation' recorded" -f Green
    if ($name) {
        Write-Host "Return to this path with 'repath $name'" -f Yellow
    } else {
        Write-Host "Return to this path with 'repath'" -f Yellow
    }
}

<#
.SYNOPSIS
    Goes to the last recorded path.

.DESCRIPTION
    This function sets the current location to the last recorded path.

.EXAMPLE
    GoToLastPath
#>
function GoToLastPath {
    $paths = Get-Content "C:\Users\$env:USERNAME\Documents\PowerShell\RecordedPaths.txt"
    $previousLocation = $paths[-1]
    if ($previousLocation -match "(.*):(.*)") {
        # If the previous location has a name associated with it
        $name, $path = $matches[1], $matches[2]
        Set-Location $path.Trim()
    } else {
        # If the previous location does not have a name associated with it
        Set-Location $previousLocation.Trim()
    }
}

<#
.SYNOPSIS
    Lists all recorded paths.

.DESCRIPTION
    This function lists all the recorded paths.

.EXAMPLE
    ListRecordedPaths
#>
function ListRecordedPaths {
    $paths = Get-Content "C:\Users\$env:USERNAME\Documents\PowerShell\RecordedPaths.txt"
    $index = 1
    $paths | ForEach-Object {
        $path = $_ | Out-String
        if ($path -match "(.*):(.*)") {
            # If the path has a name associated with it
            $name, $path = $matches[1], $matches[2]
            Write-Host "$index. $name : $path"
        } else {
            # If the path does not have a name associated with it
            Write-Host "$index. $path"
        }
        $index++
    }
}

<#
.SYNOPSIS
    Selects a recorded path to set as the current location.

.DESCRIPTION
    This function allows the user to select a recorded path and sets it as the current location.

.PARAMETER name
    The name of the recorded path to select.

.EXAMPLE
    SelectRecordedPath -name "MyPath"
#>
function SelectRecordedPath {
    param (
        [string]$name
    )
    $paths = Get-Content "C:\Users\$env:USERNAME\Documents\PowerShell\RecordedPaths.txt"
    $pathsWithNames = @()

    $paths | ForEach-Object {
        $path = $_ | Out-String
        $splitPath = $path -split ":", 2
        if ($splitPath.Length -gt 1) {
            $pathName, $path = $splitPath
        } else {
            $path = $splitPath[0].Trim()
            $pathName = $null
        }
        $pathsWithNames += [PSCustomObject]@{
            Name = $pathName.Trim()
            Path = $path.Trim()
        }
        Write-Host "$($pathsWithNames.Count). $($pathName):$path"
    }

    $selectedPath = $null

    if ($name) {
        $selectedPath = $pathsWithNames | Where-Object { $_.Name -eq $name } | Select-Object -First 1 -ExpandProperty Path
    }

    if (!$selectedPath) {
        $selection = Read-Host "Please select a recorded path to return to by number or name"
        if ($selection -match '^\d+$' -and $selection -le $pathsWithNames.Count) {
            $selectedPath = $pathsWithNames[$selection - 1].Path
        } else {
            $selectedPath = $pathsWithNames | Where-Object { $_.Name -eq $selection } | Select-Object -First 1 -ExpandProperty Path
        }
    }

    if ($selectedPath -and (Test-Path $selectedPath)) {
        Set-Location $selectedPath
    } else {
        Write-Host "The selected path '$selectedPath' does not exist."
    }
}

<#
.SYNOPSIS
    Removes a recorded path.

.DESCRIPTION
    This function allows the user to remove a recorded path.

.EXAMPLE
    RemoveOneRecordedPath
#>
function RemoveOneRecordedPath {
    $paths = Get-Content "C:\Users\$env:USERNAME\Documents\PowerShell\RecordedPaths.txt"
    $pathsWithNames = @()

    $paths | ForEach-Object {
        $path = $_ | Out-String
        $splitPath = $path -split ":", 2
        if ($splitPath.Length -gt 1) {
            $name, $path = $splitPath
            $pathsWithNames += [PSCustomObject]@{
                Name = $name.Trim()
                Path = $path.Trim()
            }
            Write-Host "$($pathsWithNames.Count). $name : $path"
        } else {
            $path = $splitPath[0].Trim()
            $pathsWithNames += [PSCustomObject]@{
                Name = $null
                Path = $path
            }
            Write-Host "$($pathsWithNames.Count). $path"
        }
    }

    $selection = Read-Host "Please select a recorded path to remove by number or name"
    $selectedPath = $pathsWithNames | Where-Object { $_.Name -eq $selection -or $_.Path -eq $selection }

    if ($selectedPath) {
        $pathsWithNames = $pathsWithNames | Where-Object { $_ -ne $selectedPath }
        $pathsWithNames | ForEach-Object { "$($_.Name) : $($_.Path)" } | Out-File "C:\Users\$env:USERNAME\Documents\PowerShell\RecordedPaths.txt"
        Write-Host "The selected path '$($selectedPath.Name) : $($selectedPath.Path)' has been removed."
    } else {
        Write-Host "The selected path '$selection' does not exist."
    }
}

<#
.SYNOPSIS
    Clears all recorded paths.

.DESCRIPTION
    This function clears all the recorded paths.

.EXAMPLE
    ClearRecordedPaths
#>
function ClearRecordedPaths {
    Clear-Content "C:\Users\$env:USERNAME\Documents\PowerShell\RecordedPaths.txt"
}

<#
.SYNOPSIS
    Lists all PowerShell shortcuts.

.DESCRIPTION
    This function lists all the PowerShell shortcuts based on the specified pattern. If no pattern is provided, it shows all shortcuts.

.PARAMETER pattern
    The pattern to filter the shortcut list.

.EXAMPLE
    PowerShellListShortcuts -pattern "MyShortcut"
#>
function PowerShellListShortcuts {
    param (
        [string]$pattern
    )
    $psCommandsPath = "C:\Users\$env:USERNAME\Documents\PowerShell\PowerShellCommands.txt"
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        Get-Content $psCommandsPath
    } else {
        Select-String -Path $psCommandsPath -Pattern $pattern
    }
}

<#
.SYNOPSIS
    Lists all Git shortcuts.

.DESCRIPTION
    This function lists all the Git shortcuts based on the specified pattern. If no pattern is provided, it shows all shortcuts.

.PARAMETER pattern
    The pattern to filter the shortcut list.

.EXAMPLE
    GitListShortcuts -pattern "MyShortcut"
#>
function GitListShortcuts {
    param (
        [string]$pattern
    )
    $gitCommandsPath = "C:\Users\$env:USERNAME\Documents\PowerShell\GitCommands.txt"
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        Get-Content $gitCommandsPath
    } else {
        Get-Content $gitCommandsPath | Where-Object { $_ -like "*$pattern*" }
    }
}

<#
.SYNOPSIS
    Lists all Conda shortcuts.

.DESCRIPTION
    This function lists all the Conda shortcuts based on the specified pattern. If no pattern is provided, it shows all shortcuts.

.PARAMETER pattern
    The pattern to filter the shortcut list.

.EXAMPLE
    CondaListShortcuts -pattern "MyShortcut"
#>
function CondaListShortcuts {
    param (
        [string]$pattern
    )
    $condaCommandsPath = "C:\Users\$env:USERNAME\Documents\PowerShell\CondaCommands.txt"
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        Get-Content $condaCommandsPath
    } else {
        Select-String -Path $condaCommandsPath -Pattern $pattern
    }
}

<#
.SYNOPSIS
    Checks SSH keys.

.DESCRIPTION
    This function checks the SSH keys in the user's .ssh directory.

.EXAMPLE
    CheckSsh
#>
function CheckSsh {
    $sshKeys = Get-ChildItem ~\.ssh\id_* | ForEach-Object {
        & ssh-keygen -l -f $_.FullName
    }
    $uniqueKeys = $sshKeys | Select-Object -Unique
    return $uniqueKeys
}

<#
.SYNOPSIS
    Adds a path for the current session.

.DESCRIPTION
    This function adds a path to the environment variable PATH for the current session.

.PARAMETER NewPath
    The path to add.

.EXAMPLE
    AddPathSession -NewPath "C:\MyPath"
#>
function AddPathSession {
    param (
        [string]$NewPath
    )
    $env:PATH += ";$NewPath"
    Write-Host "Path added for current session: $NewPath"
}

<#
.SYNOPSIS
    Adds a path permanently.

.DESCRIPTION
    This function adds a path to the environment variable PATH permanently.

.PARAMETER NewPath
    The path to add.

.EXAMPLE
    AddPathPermanent -NewPath "C:\MyPath"
#>
function AddPathPermanent {
    param (
        [string]$NewPath
    )
    $path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($path -split ';' -notcontains $NewPath) {
        $newPath = $path + ';' + $NewPath
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Path added permanently: $NewPath"
    } else {
        Write-Host "Path already exists."
    }
}

<#
.SYNOPSIS
    Searches for a command in the PATH.

.DESCRIPTION
    This function searches for a command in the PATH and returns the source of the command.

.PARAMETER Name
    The name of the command to search for.

.EXAMPLE
    SearchPath -Name "MyCommand"
#>
function SearchPath {
    param (
        [string]$Name
    )
    
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    
    if ($command) {
        if ($command.CommandType -eq 'Alias') {
            $nativeCommand = Get-Command $command.Definition -ErrorAction SilentlyContinue
            Write-Host "Alias for: $($command.Definition)"
            $nativeCommand.Source
        } else {
            $command.Source
        }
    } else {
        Write-Host "'$Name' not found in PATH. Would you like to search for commands similar to '$Name'? (y N)"
        $search = Read-Host
        
        if ($search -eq 'y') {
            SearchCommand -Keyword $Name -Application
        }
    }
}

<#
.SYNOPSIS
    Searches for commands based on a keyword and displays their names and sources.

.DESCRIPTION
    The SearchCommand function searches for commands based on a keyword and displays their names and sources. 
    It provides an option to search only for application commands.

.PARAMETER Keyword
    Specifies the keyword to search for. The default value is "*", which matches all commands.

.PARAMETER Application
    Specifies whether to search only for application commands. By default, it is set to $false.

.EXAMPLE
    SearchCommand -Keyword "Get" -Application
    Searches for application commands with the keyword "Get" and displays their names and sources.

.EXAMPLE
    SearchCommand -Keyword "Set"
    Searches for all commands with the keyword "Set" and displays their names and sources.
#>
function SearchCommand {
    [CmdletBinding()]
    param (
        [Alias("k")]
        [string]$Keyword = "*",
        [Alias("a")]
        [switch]$Application = $false
    )

    $commandType = if ($Application) { 'Application' } else { '*' }
    $selection = Get-Command -CommandType $commandType | Where-Object { $_.Name -like "*$Keyword*" } | Sort-Object Name

    if ($selection) {
        $selection | ForEach-Object {
            Write-Host "$($_.Name) : $($_.Source)"
        }
    } else {
        Write-Host "No commands found."
    }
}

<#
.SYNOPSIS
    Retrieves information about a PowerShell command.

.DESCRIPTION
    The CommandInfo function retrieves information about a PowerShell command, including its help content.
    It supports two optional switches: -Full and -Short.

.PARAMETER CommandName
    Specifies the name of the command to retrieve information for.

.PARAMETER Full
    Retrieves the full help content for the command.

.PARAMETER Short
    Retrieves a short synopsis of the command.

.EXAMPLE
    CommandInfo Get-Process -Full
    Retrieves the full help content for the Get-Process command.

.EXAMPLE
    CommandInfo Get-Service -Short
    Retrieves a short synopsis of the Get-Service command.

#>
function CommandInfo {
    param (
        [string]$CommandName,
        [Alias("f")]
        [switch]$Full,
        [Alias("s")]
        [switch]$Short
    )

    if ($CommandName) {
        # Check if both switches are set
        if ($Full -and $Short) {
            $Short = $false
        }

        # Get the command info
        $command = Get-Command $CommandName -ErrorAction SilentlyContinue
        if ($command) {
            if ($command.CommandType -eq 'Alias') {
                Write-Host "$CommandName is an alias for $($command.Definition)"
                $command = Get-Command $command.Definition -ErrorAction SilentlyContinue
            }

            if ($Full) {
                Get-Help $command.Name -Full
            } elseif ($Short) {
                (Get-Help $command.Name).Synopsis
            } else {
                Get-Help $command.Name
            }
        } else {
            Write-Host "Command '$CommandName' not found."
        }
    } else {
        Write-Host "Please specify a command name."
        $search = Read-Host
        CommandInfo $search
    }
}

<#
.SYNOPSIS
    Retrieves the current path.

.DESCRIPTION
    This function retrieves the current path using the Get-Location cmdlet and displays it using Write-Host.

.EXAMPLE
    GetPath
    Retrieves and displays the current path.

#>
function GetPath {
    $currentPath = Get-Location
    Write-Host $currentPath
}

<#
.SYNOPSIS
    Retrieves IP address information.

.DESCRIPTION
    The GetIP function retrieves IP address information based on the specified parameters.

.PARAMETER All
    Retrieves IP addresses for all network interfaces.

.PARAMETER Public
    Retrieves the public IP address.

.PARAMETER Local
    Retrieves the local IP address.

.EXAMPLE
    GetIP -All
    Retrieves IP addresses for all network interfaces.

.EXAMPLE
    GetIP -Public
    Retrieves the public IP address.

.EXAMPLE
    GetIP -Local
    Retrieves the local IP address.
#>
function GetIP {
    param (
        [Alias("a")]
        [switch]$All = $false,
        [Alias("p")]
        [switch]$Public = $false,
        [Alias("l")]
        [switch]$Local = $false
    )

    if (-not $Public) {
        $ipAddresses = Get-NetIPAddress -AddressFamily IPv4
        if ($All) {
            $ipAddresses | Select-Object -Property InterfaceAlias, IPAddress
        } else {
            $ipAddresses | Where-Object { $_.InterfaceAlias -like "Ethernet 2" } | Select-Object -Property InterfaceAlias, IPAddress
        }
    } else {
        $ipInfo = Invoke-RestMethod http://ipinfo.io/json
        if ($All) {
            Write-Host "`n$($ipInfo)`n`n"
        } else {
            Write-Host "`nPublic IP: $($ipInfo.ip) - $($ipInfo.city)`n`n"
        }
    }
}

<#
.SYNOPSIS
    Measures the execution time of a PowerShell command.

.DESCRIPTION
    The MeasureCommandExecution function measures the execution time of a PowerShell command and displays the result in milliseconds.

.PARAMETER Command
    The PowerShell command to be executed and measured.

.EXAMPLE
    MeasureCommandExecution -Command { Get-Process }

    This example measures the execution time of the Get-Process command.

#>
function MeasureCommandExecution {
    param (
        [ScriptBlock]$Command
    )

    # Measure the execution time of the command
    $executionTime = Measure-Command -Expression $Command

    # Display the execution time in milliseconds
    Write-Host "Execution Time: $($executionTime.TotalMilliseconds) ms"
}

# Custom
Set-Alias ss	    SniffSearch # File search in folder
Set-Alias c         'Clear-Host' # Quick clear the terminal screen
Set-Alias cc        ShowCommandList # List custom commands in the session
Set-Alias scc	    SearchCustomCommand # Search for a custom command
Set-Alias epin      EditProfileInCode # Edit profile config in VS Code
Set-Alias reload    ReloadProfile # Reload the profile.ps1 without restarting PowerShell
Set-Alias debloater LaunchDebloater	#Launch ChrisTitusWindowsTool
Set-Alias exetime   MeasureCommandExecution # Measure the execution time of a command
Set-Alias ~			ToRootDir # Move two directories up
Set-Alias ...       TwoDirUp # Move two directories up
Set-Alias ....      ThreeDirUp # Move three directories up
Set-Alias rpath     RecordPath # Record the current path
Set-Alias rep       RecordPath # Record the current path
Set-Alias repath    GoToLastPath # Go back to the last recorded path
Set-Alias retp      GoToLastPath # Go back to the last recorded path
Set-Alias lpath     ListRecordedPaths # List all recorded paths
Set-Alias lp        ListRecordedPaths # List all recorded paths
Set-Alias spath     SelectRecordedPath  # List all recorded paths and go back to the selected path
Set-Alias sep       SelectRecordedPath  # List all recorded paths and go back to the selected path
Set-Alias rmpath    RemoveOneRecordedPath # Selected and delete path
Set-Alias rmp       RemoveOneRecordedPath # Selected and delete path
Set-Alias clrpath   ClearRecordedPaths # Clear all recorded paths
Set-Alias clrp      ClearRecordedPaths # Clear all recorded paths
Set-Alias grep      'Select-String --color=auto' # Search with 'grep', with color highlighting
Set-Alias path      'echo $Env:PATH -split ";"' # Display the PATH environment variable
Set-Alias docs      'cd C:\Users\$env:USERNAME\Documents' # Change to the Documents directory
Set-Alias downs     'cd $HOME\Downloads' # Change to the Downloads directory
Set-Alias nano      'notepad++.exe' # Open notepad
Set-Alias touch     'ni' # Create a new file
Set-Alias path-session AddPathSession  # Add a path for the current session
Set-Alias path-permanent AddPathPermanent  # Add a path permanently
Set-Alias which     SearchPath # Search for a command in PATH
Set-Alias searchCmd SearchCommand  # Search for a command
Set-Alias cmdInfo   CommandInfo  # Show help for a command
Set-Alias ip        GetIP # Get the public and local IP address 
Set-Alias json      ConvertTo-Json # Convert to JSON
Set-Alias jsonp     ConvertFrom-Json # Convert from JSON 

# Conda
Set-Alias ccon      CondaListShortcuts # List Conda shortcuts
Set-Alias cce       CondaCreateEnv # Create a new Conda environment
Set-Alias conda-update 'conda update -n base conda' # Update the base Conda installation
Set-Alias aenv      'conda activate' # Activate a Conda environment
Set-Alias lenv      'conda env list' # List all Conda environments
Set-Alias cue       CondaUpdateEnv # Update all packages in a specified environment
Set-Alias cre       CondaRemoveEnv # Delete a Conda environment
# PowerShell
Set-Alias cps       PowerShellListShortcuts # List Conda shortcuts
Set-Alias p         GetPath # List all running processes
Set-Alias l         'Get-ChildItem -Force -Name | Format-Wide -Column 1' # List files in a format suitable for the terminal
Set-Alias ll        'Get-ChildItem -Force | Format-Table -AutoSize' # List all files in long format, including hidden files
Set-Alias la        'Get-ChildItem -Force -Name' # List all files, including hidden files, but exclude '.' and '..'
Set-Alias lsa       'Get-Alias' # List all aliases available in the session
Set-Alias getv      'Get-Variable' # Get a variable
Set-Alias setv      'Set-Variable' # Set a variable
Set-Alias newi      'New-Item' # Create a new item
Set-Alias lprompt   LoadPrompt # Customizing the PowerShell prompt appearance
Set-Alias rprompt   ResetPrompt # Resetting the PowerShell prompt appearance
Set-Alias sprompt   SetPrompt # Restyling the PowerShell prompt appearance
Set-Alias lci       ListConnectedIPs # List connected IPs
Set-Alias psadmin   LaunchAdminPS # Open PowerShell as Administrator in Current Directory
Set-Alias cdd       CreateDirectoryIfNotExists # Automatic Directory Creation with cd with Confirmation
Set-Alias ssh-check  CheckSsh # Check all available SSH keys
# Git aliases
Set-Alias cgit      GitListShortcuts # List Git shortcuts
Set-Alias gs        gitStatus # Show the Git status
Set-Alias ga        gitAdd # Add changes to the Git index
Set-Alias gaa       gitAddAll # Add all changes to the Git index
Set-Alias gb        gitBranch # Show the Git branches
Set-Alias gba       gitBranchAll # Show all Git branches, including remote branches
Set-Alias gbd       gitBranchDelete # Delete a Git branch
Set-Alias gcom      gitCommit # Commit changes to Git
Set-Alias gcoma     gitCommitAll # Commit all changes to Git
Set-Alias gcb       gitCheckoutBranch # Checkout a Git branch
Set-Alias gcl       gitClone # Clone a Git repository
Set-Alias gco       gitCheckout # Checkout a Git commit or branch
Set-Alias gcl       gitConfigList # List Git configuration settings
Set-Alias gclean    gitClean # Clean the Git working directory
Set-Alias gcmaster  gitCheckoutMaster # Checkout the master branch in Git
Set-Alias gcherry   gitCherryPickAbort # Abort a Git cherry-pick operation

# DEVELOPER
Set-Alias loadsc LoadScript # Load a script

# Set the default location to the home directory
#Set-Location $HOME

Write-Host "PowerTools Custom Profile loaded.`n"
  
#34de4b3d-13a8-4540-b76d-b9e8d3851756 PowerToys CommandNotFound module

Import-Module "C:\Program Files\PowerToys\WinUI3Apps\..\WinGetCommandNotFound.psd1"
#34de4b3d-13a8-4540-b76d-b9e8d3851756