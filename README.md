# PVM - Python Version Manager

PVM is a POSIX-compliant Python Version Manager that allows you to install, manage, and switch between multiple versions of Python, similar to how `nvm` works for Node.js.

## Features
- Install multiple Python versions.
- Switch between installed versions.
- Manage Python versions across UNIX-like systems (Linux/macOS) and Windows (PowerShell and Command Prompt).

## Installation

### macOS and Linux

#### 1. Install PVM using Homebrew (Recommended for macOS/Linux)

If you're on macOS or a Linux distribution that supports Homebrew, you can install PVM via Homebrew:

1. **Tap the repository**:
   ```bash
   brew tap rishitshivesh/pvm
   ```

2. **Install PVM**:
   ```bash
   brew install pvm
   ```

3. **Add PVM to your shell profile**:
   Add the following lines to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or equivalent):
   ```bash
   export PVM_HOME="$HOME/.pvm"
   [ -s "$PVM_HOME/pvm.sh" ] && \. "$PVM_HOME/pvm.sh"
   ```

4. **Reload your shell configuration**:
   After updating the configuration, run:
   ```bash
   source ~/.bashrc  # Or source ~/.zshrc for Zsh users
   ```

#### 2. Install PVM using `curl`

For Linux/macOS systems that don't use Homebrew, you can install PVM directly using `curl`:

1. **Install via curl**:
   ```bash
   curl -o- https://raw.githubusercontent.com/rishitshivesh/pvm/main/install.sh | bash
   ```

2. **Add PVM to your shell profile**:
   After the installation, update your shell configuration file (`~/.bashrc`, `~/.zshrc`, or equivalent):
   ```bash
   export PVM_HOME="$HOME/.pvm"
   [ -s "$PVM_HOME/pvm.sh" ] && \. "$PVM_HOME/pvm.sh"
   ```

3. **Reload your shell configuration**:
   After updating the configuration, run:
   ```bash
   source ~/.bashrc  # Or source ~/.zshrc for Zsh users
   ```

---

### Windows

PVM also supports Windows through PowerShell and Command Prompt (`cmd`). Follow the instructions below depending on the terminal you're using.

#### 1. Install and Use PVM on PowerShell

1. **Download the PowerShell script**:
   ```powershell
   Invoke-WebRequest -Uri https://raw.githubusercontent.com/rishitshivesh/pvm/main/scripts/pvm.ps1 -OutFile $HOME\.pvm\pvm.ps1
   ```

2. **Add PVM to your PowerShell profile**:
   Add the following line to your PowerShell profile (`$PROFILE`):
   ```powershell
   $env:PVM_HOME = "$HOME\.pvm"
   . "$env:PVM_HOME\pvm.ps1"
   ```

3. **Reload PowerShell**:
   Restart PowerShell or reload the profile:
   ```powershell
   . $PROFILE
   ```

4. **Add PVM to PATH (Optional)**:
   To ensure `PVM_HOME` is in your PATH, run:
   ```powershell
   pvm_add_to_path
   ```

5. **Use PVM**:
   You can now use PVM commands like `pvm install`, `pvm use`, etc.

#### 2. Install and Use PVM on Command Prompt (cmd)

1. **Download the batch script**:
   ```cmd
   curl -o %USERPROFILE%\.pvm\pvm.bat https://raw.githubusercontent.com/rishitshivesh/pvm/main/scripts/pvm.bat
   ```

2. **Add PVM to PATH (Optional)**:
   To add PVM to the `PATH` in Command Prompt, run the following:
   ```cmd
   pvm_add_to_path
   ```

3. **Use PVM**:
   Run the batch file by navigating to the `.pvm` folder or by adding it to your environment's PATH:
   ```cmd
   %USERPROFILE%\.pvm\pvm.bat install 3.9.7
   ```

   To switch between versions, you can run:
   ```cmd
   %USERPROFILE%\.pvm\pvm.bat use 3.9.7
   ```

---

## Usage

Once PVM is installed, you can manage different Python versions using the following commands:

### Install a Python Version

To install a specific Python version (e.g., Python 3.9.7):

```bash
pvm install 3.9.7
```

If you only specify the major or minor version, PVM will automatically install the latest patch version:

```bash
pvm use 3     # Install the latest version of Python 3.x.x
pvm use 3.10  # Install the latest version of Python 3.10.x
```

### Use a Python Version

To switch between installed Python versions:

```bash
pvm use 3.9.7
```

This will set the current shell to use Python 3.9.7.

### List Installed Versions

To list all installed Python versions:

```bash
pvm ls
```

### Uninstall a Python Version

To uninstall a specific Python version:

```bash
pvm uninstall 3.9.7
```

---

## Contributing

1. Fork the repository on GitHub.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

We welcome contributions from the community to improve and extend PVM!

---

## License

PVM is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.

---

## Troubleshooting

If you encounter any issues while using PVM, please check the following:

- Ensure that the `PVM_HOME` environment variable is set correctly.
- Make sure the correct Python version is installed and that the version exists in your `PVM_HOME/versions` folder.

If the problem persists, feel free to open an issue on the [GitHub repository](https://github.com/rishitshivesh/pvm/issues).

---

## Future Enhancements

We are continuously improving PVM, and here are some planned features:

- Support for pre-built Python binaries for faster installations.
- Integration with other package managers.
- Enhanced support for Windows installations.

Stay tuned for more updates!

---

## Author:
Rishit Shivesh | [github](https://github.com/) | [portfolio](https://rishit.co.in)