$PVM_HOME = "$HOME\.pvm"
$env:PVM_HOME = $PVM_HOME
New-Item -Path $PVM_HOME\versions -ItemType Directory -Force

function pvm_install {
    param([string]$version)

    $pythonURL = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
    Invoke-WebRequest -Uri $pythonURL -OutFile "$PVM_HOME\python-$version.exe"

    Start-Process -FilePath "$PVM_HOME\python-$version.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

    Remove-Item "$PVM_HOME\python-$version.exe"
}

function pvm_use {
    param([string]$version)

    if (!(Test-Path "$PVM_HOME\versions\$version")) {
        Write-Host "Version $version is not installed."
        return
    }

    $env:PATH = "$PVM_HOME\versions\$version\bin;$env:PATH"
    Write-Host "Now using Python $version"
}

function pvm_list {
    Get-ChildItem -Directory "$PVM_HOME\versions" | ForEach-Object { $_.Name }
}

function pvm_uninstall {
    param([string]$version)

    Remove-Item -Recurse -Force "$PVM_HOME\versions\$version"
    Write-Host "Python $version uninstalled"
}

function pvm_add_to_path {
    $PVM_HOME = "$HOME\.pvm"
    $env:PVM_HOME = $PVM_HOME

    if ($env:PATH -notlike "*$PVM_HOME*") {
        # Temporarily add PVM_HOME to the current session PATH
        $env:PATH = "$PVM_HOME\bin;$env:PATH"

        # Persist the change by modifying the User's PATH environment variable
        [System.Environment]::SetEnvironmentVariable("Path", "$PVM_HOME\bin;$([System.Environment]::GetEnvironmentVariable('Path', 'User'))", "User")

        Write-Host "PVM_HOME has been added to PATH permanently."
    } else {
        Write-Host "PVM_HOME is already in PATH."
    }
}

# Add command aliases for user-friendly commands
Set-Alias pvm_install pvm_install
Set-Alias pvm_use pvm_use
Set-Alias pvm_list pvm_list
Set-Alias pvm_uninstall pvm_uninstall
Set-Alias pvm_add_to_path pvm_add_to_path
