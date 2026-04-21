# TCC-Bridge

A lightweight Bash wrapper for the **Tuxedo Control Center (TCCD)** via D-Bus. This script allows me to manage power profiles through the CLI or a keyboard shortcuts (like the F3 Power Mode button) without needing the GUI open.

## Features
* **Cycle Profiles:** Switch to the next available power profile.
* **Direct Selection:** Jump to a specific profile using its ID.
* **List Profiles:** View all available profiles with their IDs.
* **Status Reporting:** Get the currently active profile in a clean format.

## Prerequisites
* `tuxedo-control-center` (running the background daemon `tccd`)
* `jq` (for JSON parsing)
* `gdbus` (usually included with `glib2`)
* `notify-send` (optional, for desktop notifications)

## Usage

### Commands
| Flag | Description |
| :--- | :--- |
| `-n`, `--next` | Cycles to the next power profile in the list. |
| `-c`, `--current` | Displays the name and ID of the currently active profile. |
| `-l`, `--list` | Lists all available profiles and their IDs. |
| `-s`, `--set [ID]` | Sets the power profile to the specified ID. |

### Examples
```bash
# See what is currently running
./tcc-switch.sh --current

# List all available profiles
./tcc-switch.sh --list

# Switch to the 'quiet' profile
./tcc-switch.sh --set quiet

# Cycle to the next profile
./tcc-switch.sh --next
```

---

## Technical Details
This script communicates with the `com.tuxedocomputers.tccd` system bus. It uses `mapfile` to safely handle the JSON arrays returned by the TCC daemon, ensuring that multi-word profile names are treated as single strings.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
