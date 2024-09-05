# Pre-Commit Setup with Gitleaks

This repository includes scripts to automatically set up Gitleaks as a pre-commit hook in your local Git environment. 

**Gitleaks** is a tool that scans your code for secrets before they are committed, helping you prevent accidental exposure of sensitive information.

## Files in This Repository

 * `setup_gitleaks.sh`: A script to install Gitleaks and set it up as a pre-commit hook.
 * `.gitleaks.toml`: A configuration file containing custom rules for Gitleaks.

### No sudo Required (for Linux users):

The script is designed to install Gitleaks entirely within your user space, specifically in your home directory (`$HOME/.local/bin`). This means that no administrative privileges (`sudo`) are required, making it safe and easy to use even on systems where you don't have root access.

## Installation Guide

### 1: Run the Setup Scrip

To install Gitleaks and configure it as a pre-commit hook, you can run the following single command:

```sh
curl https://raw.githubusercontent.com/YuriiKosiy/pre-commit/main/setup_gitleaks.sh | sh
```

### 2: Alternatively, you can download the script manually and Run
Clone this repository to your local machine:

```bash
git clone https://github.com/YuriiKosiy/pre-commit.git
cd pre-commit
```

Run it manualy:

```bash
./setup_gitleaks.sh
```
**The script will:**

 1. Check if Gitleaks is already installed. If not, it will download and install it in your home directory (`$HOME/.local/bin`).
 2. Set up the pre-commit hook to automatically run Gitleaks before each commit.
 3. Use the custom rules specified in `.gitleaks.toml`, if available.

### 3: Verify the Installation

You can verify that Gitleaks is installed correctly by checking its version:
```bash
gitleaks version
```

### Step 4: Enabling/Disabling the Pre-Commit Hook

The pre-commit hook can be enabled or disabled as needed:

 * Enable the pre-commit hook:
 ```bash
 git config hooks.gitleaks true
 ```
 * Disable the pre-commit hook:
 ``` bash
 git config hooks.gitleaks false
 ```

## How It Works

 * **On Every Commit:** When you attempt to commit changes, Gitleaks will automatically scan the staged files for secrets. If any secrets are found, the commit will be blocked, and you'll be provided     with details on what needs to be addressed.
 * **Custom Rules:** The .gitleaks.toml file contains custom rules that define what Gitleaks considers a "secret". You can modify this file to adjust the scanning behavior to fit your project's needs.

## Troubleshooting

**Installation Issues**

If the script fails to install Gitleaks:

* **Permissions**: Ensure that you have the necessary permissions to write to your home directory. 

If problems persist, consider manually installing Gitleaks from the <a rel="noopener" target="_new" href="https://github.com/gitleaks/gitleaks">official repository</a>.

### Path Issues (Linux)

If the terminal cannot find Gitleaks after installation (`command not found`), you may need to add `$HOME/.local/bin` to your `PATH`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

To make this change permanent, add the above line to your `~/.bashrc` or `~/.zshrc` file and reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc for Zsh users
```

## Conclusion

This setup script is designed to help you integrate Gitleaks into your development workflow with minimal effort. By following these steps, you can ensure that your commits are free of sensitive information, maintaining the security and integrity of your project.

