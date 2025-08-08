#!/bin/bash

URL="https://mycampuz.co.in/visitor"

# (Assuming Chrome is already installed and xdotool too)

# Open Chrome with the URL
google-chrome --start-fullscreen "$URL" &
sleep 5  # Wait for page to load

# Get Chrome window id
CHROME_WIN_ID=$(xdotool search --onlyvisible --class "chrome" | head -n 1)

# Countdown before typing
echo "⏳ Waiting for 10 seconds before typing..."
for i in {10..1}; do
    echo "$i..."
    sleep 1
done

# Activate Chrome window
xdotool windowactivate "$CHROME_WIN_ID"
sleep 1

# Click inside the webpage to focus
xdotool mousemove --window "$CHROME_WIN_ID" 300 300 click 1
sleep 0.5

# Tab into the input, type 123, and press Enter
xdotool key Tab
sleep 0.3
xdotool type "123"
sleep 0.3
xdotool key Return
