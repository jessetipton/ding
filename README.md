# ding

`ding` is a tiny Zsh plugin for macOS that plays one of the built-in system sounds after a long-running command finishes. It gives you a quick audible confirmation without needing to stare at the terminal: a positive sound for successful commands and a negative sound when something fails.

## Requirements

- macOS (relies on `/System/Library/Sounds` and `afplay`)
- Zsh 5.4+ (anything that provides `EPOCHREALTIME` and `add-zsh-hook`)

## Installation

Clone this repository somewhere on your machine, then source the plugin from your `.zshrc`:

```zsh
git clone https://github.com/your-user/ding.git ~/.zsh/ding
source ~/.zsh/ding/ding.plugin.zsh
```

Using a plugin manager:

- **Oh My Zsh**: add `ding` as a [custom plugin](https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#overriding-and-adding-plugins) that sources the `ding.plugin.zsh` file.
- **Antidote / Znap / Zgenom / etc.**: treat this repo as any other plugin by referencing its git URL.

## Configuration

All configuration is done through environment variables that can be set before sourcing the plugin (or anytime in your `.zshrc` before the hook runs):

| Variable | Default | Description |
| --- | --- | --- |
| `DING_MIN_DURATION` | `5` | Minimum command runtime (seconds) required before a sound plays. Accepts floats, e.g. `1.5`. |
| `DING_SUCCESS_SOUND` | `Glass` | Name of the system sound (`/System/Library/Sounds/<name>.aiff`) to use for successful commands. |
| `DING_FAILURE_SOUND` | `Basso` | Sound to play when the command exits with a non-zero status. |

Example configuration:

```zsh
export DING_MIN_DURATION=3
export DING_SUCCESS_SOUND=Hero
export DING_FAILURE_SOUND=Sosumi
source ~/.zsh/ding/ding.plugin.zsh
```

You can run `ls /System/Library/Sounds` to see the available sound names.

## How it works

`ding` registers lightweight `preexec` and `precmd` hooks. The `preexec` hook records when each foreground command starts, and the `precmd` hook fires after the command finishes. If the runtime exceeds your configured threshold, the plugin plays either the success or failure sound asynchronously via `afplay`, so your prompt remains responsive.
