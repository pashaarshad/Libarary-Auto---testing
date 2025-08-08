#!/bin/bash

URL="https://mycampuz.co.in/visitor"

# Check and install Chrome if not installed
if ! command -v google-chrome &> /dev/null; then
    echo "🚀 Google Chrome not found. Installing..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
    sudo apt install -y /tmp/chrome.deb
fi

# Install xdotool if not installed
if ! command -v xdotool &> /dev/null; then
    echo "🚀 Installing xdotool..."
    sudo apt install -y xdotool
fi

# Open Chrome with URL
google-chrome "$URL" &
sleep 5  # wait for Chrome to open

# Activate Chrome window
CHROME_WIN_ID=$(xdotool search --onlyvisible --class "chrome" | head -n 1)
xdotool windowactivate "$CHROME_WIN_ID"

# Open Developer Console (Ctrl+Shift+J)
xdotool key --window "$CHROME_WIN_ID" ctrl+shift+j
sleep 2

# Type your JavaScript code into the console
xdotool type --window "$CHROME_WIN_ID" "setTimeout(() => { const input = document.querySelector('input[name=\"memid\"]'); if (input) { input.value = '123'; input.dispatchEvent(new Event('input', { bubbles: true })); } const button = document.querySelector('button[type=\"submit\"]'); if (button) { button.click(); } }, 2000);"
xdotool key --window "$CHROME_WIN_ID" Return
