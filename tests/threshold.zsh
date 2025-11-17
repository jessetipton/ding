#!/usr/bin/env zsh

set -e
set -u
set -o pipefail

script_dir=${0:A:h}
repo_dir=${script_dir:h}

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/ding-threshold.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT INT TERM

log_file="$tmpdir/sounds.log"
: >"$log_file"

export DING_MIN_DURATION=0.2
source "$repo_dir/ding.plugin.zsh"

# Override the sound player so the test can inspect when it fires.
ding__play_sound() {
  emulate -L zsh
  print -r -- "$1" >>"$log_file"
}

reset_log() {
  : >"$log_file"
}

assert_no_sound() {
  local message=$1
  if [[ -s $log_file ]]; then
    print -u2 -- "$message"
    cat "$log_file" >&2
    exit 1
  fi
}

assert_sound_count() {
  local expected=$1
  local message=$2
  local actual=0
  if [[ -f $log_file ]]; then
    actual=$(wc -l <"$log_file")
  fi
  if (( actual != expected )); then
    print -u2 -- "$message (expected $expected, saw $actual)"
    cat "$log_file" >&2
    exit 1
  fi
}

simulate_command() {
  local duration=$1
  local exit_code=$2

  ding__preexec
  zsh -c "sleep $duration; exit $exit_code"
  ding__precmd
}

# precmd should be a no-op until a command actually ran.
reset_log
ding__precmd
assert_no_sound "precmd before any command should not play sounds."

# Commands shorter than the minimum must stay silent.
reset_log
simulate_command 0.1 0
assert_no_sound "Commands under DING_MIN_DURATION should not play sounds."
# Re-running precmd without a new command must still be silent (regression guard).
ding__precmd
assert_no_sound "precmd should stay silent after skipping a short command."

# Long-running successes must trigger the sound exactly once.
reset_log
simulate_command 0.3 0
assert_sound_count 1 "Long-running successes should trigger one sound."
# A spurious precmd run after the command should do nothing.
ding__precmd
assert_sound_count 1 "Extra precmd runs should not play additional sounds."

# Failures have the same duration rules.
reset_log
simulate_command 0.3 1
assert_sound_count 1 "Long-running failures should trigger one sound."

reset_log
simulate_command 0 1
assert_no_sound "Short failures should remain silent."

print -r -- "All threshold checks passed."
