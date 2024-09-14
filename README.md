# PVM - Python Version Manager

PVM is a POSIX-compliant Python Version Manager that allows you to install, manage, and switch between multiple versions of Python, similar to `nvm` for Node.js.

## Features
- Install multiple Python versions
- Switch between installed versions
- Manage Python versions on UNIX-like systems and Windows

## Installation

### POSIX (Linux/macOS)
1. Install PVM using Homebrew:

   ```bash
   brew tap rishitshivesh/pvm
   brew install pvm
   ```

2. Add the following to your shell profile (`.bashrc`, `.zshrc`, etc.):

   ```bash
   export PVM_HOME="$HOME/.pvm"
   [ -s "$PVM_HOME/pvm.sh" ] && \. "$PVM_HOME/pvm.sh"
   ```

3. Source the profile to load PVM:

   ```bash
   source ~/.bashrc  # or ~/.zshrc for zsh users
   ```

### Windows
1. Download `pvm.ps1` or `pvm.bat` from the repository.
2. Add `PVM_HOME` to your system’s PATH.

```powershell
# PowerShell version
$env:PVM_HOME = "$HOME\.pvm"
```

## Usage

#### Install a Python Version
```bash
pvm install 3.9.7
```

#### Use a Python Version
```bash
pvm use 3.9.7
```

#### Add `PVM_HOME` to `PATH`
```bash
pvm add-to-path
```

## Contributing
Feel free to submit issues or pull requests. We welcome contributions!
