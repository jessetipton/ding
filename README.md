# ding

`ding` is a lightweight Zsh plugin that plays notification sounds when a long-running shell command completes.

## Requirements

- macOS
- Zsh 5.4+

## Installation

Clone this repository somewhere on your machine, then source the plugin from your `.zshrc`:

```zsh
git clone https://github.com/jessetipton/ding.git ~/.zsh/ding
source ~/.zsh/ding/ding.plugin.zsh
```

Using a plugin manager:

- **Oh My Zsh**: add `ding` as a [custom plugin](https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#overriding-and-adding-plugins) that sources the `ding.plugin.zsh` file.
- **Antidote / Znap / Zgenom / etc.**: treat this repo as any other plugin by referencing its git URL.

## Configuration

All configuration is done through environment variables that can be set before sourcing the plugin (or anytime in your `.zshrc` before the hook runs):

| Variable | Default | Description |
| --- | --- | --- |
| `DING_MIN_DURATION` | `5` | Minimum command runtime (in seconds) required before a sound plays. |
| `DING_SUCCESS_SOUND` | `Glass` | Name of the system sound (`/System/Library/Sounds/<name>.aiff`) to use for successful commands. |
| `DING_FAILURE_SOUND` | `Basso` | Name of the system sound to play when the command exits with a non-zero status. |

Example configuration:

```zsh
export DING_MIN_DURATION=3
export DING_SUCCESS_SOUND=Hero
export DING_FAILURE_SOUND=Sosumi
```

You can run `ls /System/Library/Sounds` to see the available sound names.
