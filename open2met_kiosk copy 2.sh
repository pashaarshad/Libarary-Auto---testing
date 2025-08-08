#!/bin/bash

URL="https://mycampuz.co.in/visitor"

# Install Chrome if missing
if ! command -v google-chrome &> /dev/null; then
    echo "🚀 Installing Google Chrome..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
    sudo apt install -y /tmp/chrome.deb
fi

# Install xdotool if missing
if ! command -v xdotool &> /dev/null; then
    echo "🚀 Installing xdotool..."
    sudo apt install -y xdotool
fi

# Open Chrome with the site
google-chrome --start-fullscreen "$URL" &
sleep 5  # Wait for page to load

# Get Chrome window
CHROME_WIN_ID=$(xdotool search --onlyvisible --class "chrome" | head -n 1)
xdotool windowactivate "$CHROME_WIN_ID"

# Tab into the input, type 123, and press Enter
xdotool key Tab
sleep 0.3
xdotool type "123"
sleep 0.3
xdotool key Return
