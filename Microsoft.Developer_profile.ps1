function ReloadThisProfile {
    . $PROFILE # This profile is run once when PowerShell starts up.
}

# Customize the PowerShell prompt appearance.
function ReStylePrompt {
    param(
        [string]$prompt = "$PWD> "
    )
    $prompt = $prompt -replace 'Microsoft.PowerShell.Core\FileSystem::', '' -replace '\\', '/'  # Remove the path prefix and replace backslashes with forward slashes.
}

function ResetStylePrompt {
    $prompt = "$PWD> "
}

function SniffSearch {
    param (
        [String]$firstParam = $null,
        [String]$secondParam = $null,
        [switch]$optionParam = $null,
        [switch]$optReservedParam = $null
    )

    [int]$depth = 0
    [String]$searchString = $null
    $currentLocation = Get-Location
    
    # Check if $firstParam is $null
    if (-not [String]::IsNullOrWhiteSpace($firstParam)) {
        # Try to parse the first parameter as an integer for depth
        if ([int]::TryParse($firstParam, [ref]$depth)) {
            $searchString = $secondParam
        
        } else {
            $searchString = $firstParam
            if (-not ([String]::IsNullOrWhiteSpace($secondParam))) {
                ([int]::TryParse($secondParam, [ref]$depthParsed))
            }
        }
    }

    #Testing switches
    if ($noFolders) {
        Write-Host "No folders"
    }
    if ($noFiles) {
        Write-Host "No files"
    }

    # Search for Directories 
    if (-not $noFolders) { 
        #Write-Host "Directories:" (Get-ChildItem -Path $currentLocation)
        Write-Host "Directories:" (Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth $depth | Where-Object { $_.Name -like $searchString } | Sort-Object -Property Name | Format-Table Name)
    }

    # Search for Files 
    if (-not $noFiles) { 
        Write-Host "Files:" Get-ChildItem -Path $currentLocation -File -Recurse -Depth $depth | Where-Object { $_.Name -like $searchString } | Sort-Object -Property Name | Format-Table Name 
    }

    function sortItems { 
        param ( 
            [Parameter(Mandatory)] 
            [ValidateSet("Directory","File" )] 
            [string]$itemType 
        ) 

        # determine the type to filter 
        $typefilter=switch ($itemtype) {
            "directory" { [system.io.directoryinfo] }
            "file" { [system.io.fileinfo] }    
        } 

        # Get items and store them in a variable 
        $Items=Get-ChildItem -Path $currentLocation -Recurse -Depth $depth | Where-Object { $_ -is $typeFilter } 
        
        if (-not [string]::IsNullOrWhiteSpace($searchString)) { 
            $Items=$Items | Where-Object { $_ -is $typeFilter } 
        } 
        
        $FilteredItems = $Items | Where-Object { $_.Name -like $searchString } 
        
        Write-Host "FilteredItems: $FilteredItems"
        
        foreach ($item in $FilteredItems) { 
            Write-Host "Directories:" (Get-ChildItem -Path $currentLocation)
            Write-Host "`nFull name: $($item.Name)"
        }
        
        $FilteredItems = $Items.Name 
        if ($itemType -eq "Directory" ) { 
            foreach ($item in $Items) { 
                Write-Host "`nFull name: $($item.Name)"
            } 
        }

        $itemsGrid=$Items.Name 
        # $Items | Format-Wide -Column 3
    } 
    
    # Initiate file/folder search
    Write-Host "`nDirectories:" 
    sortItems -ItemType Directory 
    Write-Host "`nFiles:" 
    sortItems -ItemType File
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
    gitListShortcuts $pattern
    # CondaListShortcuts $pattern
}

function SearchCustomCommand {
    param (
        [string]$pattern
    )
    $customCommandsPath = "C:\Users\$env:USERNAME\Documents\PowerShell\CustomCommands.txt"
    Get-Content $customCommandsPath -Raw -match "$pattern`:\n(.*\n)?(?=\n[A-Z])"
    $matches[0]
}

function CondaRemoveEnv { 
    param (
        [string]$envName
    ) 
        conda remove -n $envName --all 
}

function ListConnectedIPs { 
    ipconfig | Select-String -Pattern 'IPv4' 
} 

function LaunchAdminPS { 
    $currentLocation = Get-Location Start-Process "C:\Program Files\PowerShell\7\pwsh.exe" -Verb RunAs -ArgumentList "-NoExit", "-Command Set-Location -LiteralPath '$home'" 
} 

function LaunchDebloater { 
    Start-Process PowerShell -ArgumentList "-Command `" iwr -useb https: christitus.com win | iex`"" -Verb RunAs 
} 

function CreateDirectoryIfNotExists {
    param(
        [string]$path
    ) 
    
    if (!(Test-Path $path)) {
        $create=Read-Host "Directory'$path' does not exist. Do you want to create it? (y N)" 
        if ($create -eq 'y' ) { 
            New-Item -ItemType Directory -Path $path | Out-Null Set-Location $path 
        } 
    } else { 
        Set-Location $path 
    }
} 

function TwoDirUp {
	cd ..\..\..
}

function ThreeDirUp {
	cd ..\..\..\..
}


function ToRootDir {
	cd ~\..\..\..
}

function EditPrompt {
    "$PWD> " 
}

function EditProfileInCode {
    code "C:\Users\$env:USERNAME\Documents\PowerShell\CustomCommands.txt" $PROFILE
}

function UpdateDevProfile {
    . 'C:\Users\david\Documents\PowerShell\update_dev_profile.ps1'
}

function gitListShortcuts {
    param (
        [string]$pattern
    )
    $gitCommandsPath = "C:\Users\$env:USERNAME\Documents\PowerShell\GitCommands.txt"
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        Get-Content $gitCommandsPath
    } else {
        Select-String -Path $gitCommandsPath -Pattern $pattern
    }
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

function loadScript {
    param (
        [string]$fileName
    )

    $scriptPath = "C:\Users\$env:USERNAME\Documents\PowerShell\$fileName"

    # Create the new profile
    New-Item -Path $scriptPath -ItemType File -Force

    # Load the new profile
    . $newProfilePath
}

# Custom
Set-Alias ss	    SniffSearch # File search in folder
Set-Alias c         'Clear-Host' # Quick clear the terminal screen
Set-Alias cc        ShowCommandList # List custom commands in the session
Set-Alias scc	    SearchCustomCommand # Search for a custom command
Set-Alias epin      EditProfileInCode # Edit profile config in VS Code
Set-Alias reload    ReloadThisProfile # Reload the profile.ps1 without restarting PowerShell
Set-Alias debloater LaunchDebloater	#Launch ChrisTitusWindowsTool
Set-Alias ~			ToRootDir # Move two directories up
Set-Alias ...       TwoDirUp # Move two directories up
Set-Alias ....      ThreeDirUp # Move three directories up
Set-Alias grep      'Select-String --color=auto' # Search with 'grep', with color highlighting
Set-Alias path      'echo $Env:PATH -split ";"' # Display the PATH environment variable
Set-Alias docs      'cd C:\Users\$env:USERNAME\Documents' # Change to the Documents directory
Set-Alias downs     'cd $HOME\Downloads' # Change to the Downloads directory
Set-Alias nano      'notepad++.exe' # Open notepad
Set-Alias touch     'ni' # Create a new file
# Conda
Set-Alias ccon      CondaListShortcuts # List Conda shortcuts
Set-Alias cce       CondaCreateEnv # Create a new Conda environment
Set-Alias conda-update 'conda update -n base conda' # Update the base Conda installation
Set-Alias aenv      'conda activate' # Activate a Conda environment
Set-Alias lenv      'conda env list' # List all Conda environments
Set-Alias cue       CondaUpdateEnv # Update all packages in a specified environment
Set-Alias cre       CondaRemoveEnv # Delete a Conda environment
# PowerShell
Set-Alias l         'Get-ChildItem -Force -Name | Format-Wide -Column 1' # List files in a format suitable for the terminal
Set-Alias ll        'Get-ChildItem -Force | Format-Table -AutoSize' # List all files in long format, including hidden files
Set-Alias la        'Get-ChildItem -Force -Name' # List all files, including hidden files, but exclude '.' and '..'
Set-Alias lsa       'Get-Alias' # List all aliases available in the session
Set-Alias getv      'Get-Variable' # Get a variable
Set-Alias setv      'Set-Variable' # Set a variable
Set-Alias newi      'New-Item' # Create a new item
Set-Alias rsp       ReStylePrompt # Customizing the PowerShell prompt appearance
Set-Alias rspreset  ResetStylePrompt # Resetting the PowerShell prompt appearance
Set-Alias lci       ListConnectedIPs # List connected IPs
Set-Alias psadmin   LaunchAdminPS # Open PowerShell as Administrator in Current Directory
Set-Alias cdd       CreateDirectoryIfNotExists # Automatic Directory Creation with cd with Confirmation
Set-Alias checkssh  'for key in ~/.ssh/id_*; do ssh-keygen -l -f "${key}"; done | uniq' # Check all available SSH keys
# Git
Set-Alias gs        gitStatus
Set-Alias ga        gitAdd
Set-Alias gaa       gitAddAll
Set-Alias gb        gitBranch
Set-Alias gba       gitBranchAll
Set-Alias gbd       gitBranchDelete
Set-Alias gcom      gitCommit
Set-Alias gcoma     gitCommitAll
Set-Alias gcb       gitCheckoutBranch
Set-Alias gcl       gitClone
Set-Alias gco       gitCheckout
Set-Alias gcl       gitConfigList
Set-Alias gclean    gitClean
Set-Alias gcmaster  gitCheckoutMaster
Set-Alias gcherry   gitCherryPickAbort
# DEV
Set-Alias loadsc   loadScript # Load a script

Write-Host "PowerTools Profile loaded.`n"

Set-Alias loadsc   loadScript # Load a script
