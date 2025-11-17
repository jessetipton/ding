#!/usr/bin/env zsh
# ding: play a macOS system sound when long commands finish

emulate -L zsh

# Ensure add-zsh-hook is available for attaching our handlers.
if ! typeset -f add-zsh-hook >/dev/null; then
  autoload -Uz add-zsh-hook || {
    print -u2 "ding: unable to autoload add-zsh-hook"
    return 1
  }
fi

# User configurable settings with sensible defaults.
typeset -gF DING_MIN_DURATION=${DING_MIN_DURATION:-5}
typeset -g DING_SUCCESS_SOUND=${DING_SUCCESS_SOUND:-Glass}
typeset -g DING_FAILURE_SOUND=${DING_FAILURE_SOUND:-Basso}

# Internal state tracking when the last command started.
typeset -gF _ding_last_cmd_started_at=0
typeset -g _ding_hooks_installed=

ding__play_sound() {
  emulate -L zsh
  local sound_name=$1
  local sound_path="/System/Library/Sounds/${sound_name}.aiff"

  if [[ ! -r $sound_path ]]; then
    return
  fi

  if ! (( $+commands[afplay] )); then
    return
  fi

  # Play asynchronously so the shell prompt is not blocked.
  afplay "$sound_path" >/dev/null 2>&1 &!
}

ding__preexec() {
  emulate -L zsh
  zmodload zsh/datetime 2>/dev/null
  _ding_last_cmd_started_at=$EPOCHREALTIME
}

ding__precmd() {
  emulate -L zsh

  local exit_status=$?
  local now duration

  zmodload zsh/datetime 2>/dev/null
  now=$EPOCHREALTIME
  (( duration = now - _ding_last_cmd_started_at ))

  if (( duration < DING_MIN_DURATION )); then
    return
  fi

  if (( exit_status == 0 )); then
    ding__play_sound "$DING_SUCCESS_SOUND"
  else
    ding__play_sound "$DING_FAILURE_SOUND"
  fi
}

ding__install_hooks() {
  emulate -L zsh

  if [[ $_ding_hooks_installed == 1 ]]; then
    return
  fi

  add-zsh-hook preexec ding__preexec
  add-zsh-hook precmd ding__precmd

  _ding_hooks_installed=1
}

ding__install_hooks
