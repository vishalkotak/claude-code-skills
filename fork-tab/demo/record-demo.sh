#!/usr/bin/env bash
# Records the README demo: a main Claude session, a /fork-tab tangent in a new
# tab, then back to the untouched original. Drives Ghostty via AppleScript and
# records the main display with `screencapture -v`.
# Requires: Ghostty has Screen Recording permission; ffmpeg + gifski.
# Usage: CROP=w:h:x:y record-demo.sh <out-dir>
#   CROP is the demo window's rectangle in display pixels (Retina = 2x points).
#   Always set it: the recording is full-screen, so without a crop every other
#   window on your desktop ends up in the GIF. Find it from a frame of demo.mov.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
out="${1:?usage: record-demo.sh <out-dir>}"; mkdir -p "$out"
claude_bin=$(command -v claude)

gs() { osascript -e "tell application \"Ghostty\" to $1"; }
# Type text one character at a time into tab <n> of the demo window, then Enter.
type_in() {
  osascript - "$1" "$2" <<'AS'
on run argv
  set n to (item 1 of argv) as integer
  set s to item 2 of argv
  tell application "Ghostty"
    set t to focused terminal of tab n of window 1
    repeat with c in characters of s
      input text (c as text) to t
      delay 0.035
    end repeat
    delay 0.4
    send key "enter" to t
  end tell
end run
AS
}

osascript - "$here/sample" "$claude_bin" "PATH=$PATH" <<'AS'
on run argv
  tell application "Ghostty"
    set cfg to new surface configuration
    set initial working directory of cfg to item 1 of argv
    set command of cfg to (item 2 of argv)
    set environment variables of cfg to {item 3 of argv}
    set w to new window with configuration cfg
    activate
  end tell
end run
AS
sleep 4; gs 'send key "enter" to focused terminal of selected tab of window 1'  # accept trust prompt if shown
sleep 3

screencapture -v -x -D 1 -V 95 "$out/demo.mov" &
rec=$!
sleep 2
type_in 1 "In one sentence: what does rate_limiter.py do?"
sleep 18
type_in 1 "/fork-tab"
sleep 8
type_in 2 "Tangent: how would a token bucket compare to this design? Two sentences."
sleep 22
gs 'select tab (tab 1 of window 1)'
sleep 3
type_in 1 "Suggest one edge-case unit test for allow()."
wait $rec

gs 'close window (window 1)' || true
crop="${CROP:+crop=$CROP,}"
ffmpeg -y -loglevel error -i "$out/demo.mov" \
  -vf "${crop}setpts=PTS/1.5,fps=10,scale=1400:-1:flags=lanczos" "$out/frame%04d.png"
gifski --quiet --fps 10 --width 1400 --quality 70 -o "$out/demo.gif" "$out"/frame*.png
rm "$out"/frame*.png
echo "$out/demo.gif"
