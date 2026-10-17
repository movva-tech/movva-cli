# Movva CLI

Install the Movva command-line interface to authenticate with Movva, run
agents and robots, inspect your local Python environment, and manage the
`movva-tech-library` Python package.

This repository distributes the release installers. Source code and release
automation are maintained separately.

## Install

### macOS and Linux

Download and run the installer:

```bash
curl -fsSLO https://raw.githubusercontent.com/movva-tech/movva-cli/main/install.sh
chmod +x install.sh
./install.sh
```

The installer detects Linux or macOS and your CPU architecture, downloads the
latest release, and installs `movva` in `/usr/local/bin`. It requires `curl`,
`tar`, and `sudo` when `/usr/local/bin` is not writable.

### Windows

From PowerShell, download and run the installer:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/movva-tech/movva-cli/main/install.ps1 -OutFile install.ps1
.\install.ps1
```

The installer downloads `movva` to `$env:LOCALAPPDATA\movva` and adds that
directory to your user `PATH`. Start a new terminal if `movva` is not yet
available after installation.

## Verify the installation

```bash
movva --help
movva env check
```

## Get started

Authenticate with an API key from the Movva web panel:

```bash
movva auth <api-key>
```

The CLI stores its configuration in `~/.movva.yaml`. Use a different file with
the global `--config` option:

```bash
movva --config ./movva.yaml agent list
```

Common commands:

```bash
movva agent list
movva agent get <agent-id>
movva agent run <agent-id> --prompt "Summarize today's support tickets"

movva robot list
movva robot get <robot-id>
movva robot run <robot-id>

movva lib install
movva lib list
movva lib use <version>
```

Run `movva --help` or `movva <command> --help` to see all available commands.

## Requirements

- A Movva API key for agent and robot commands.
- Python 3 and either `pip` or `uv` for `movva lib` commands.

## Releases and support

Download versioned archives and checksums from the
[GitHub Releases page](https://github.com/movva-tech/movva-cli/releases).
For source changes or release maintenance, use the private maintainer
repository.
