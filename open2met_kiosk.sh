#!/bin/bash

# First URL where you input the code
FIRST_URL="https://mycampuz.co.in/visitor"

# Second URL to open after closing Chrome
SECOND_URL="https://mycampuz.co.in/visitor/#/visitor"

# Function to open Chrome and automate input
run_first_url() {
  google-chrome --start-fullscreen "$FIRST_URL" &
  CHROME_PID=$!
  sleep 5  # wait for page load

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

  # Click inside webpage to focus
  xdotool mousemove --window "$CHROME_WIN_ID" 300 300 click 1
  sleep 0.5

  # Tab, type '123' and press Enter
  xdotool key Tab
  sleep 0.3
  xdotool type "123"
  sleep 0.3
  xdotool key Return

  # Wait 4 seconds after submission
  sleep 4

  # Kill Chrome completely
  echo "🛑 Closing Chrome..."
  kill $CHROME_PID
  sleep 3
}

# Function to open Chrome with second URL fullscreen
run_second_url() {
  google-chrome --start-fullscreen "$SECOND_URL" &
  echo "🚀 Opened second URL in fullscreen."
}

# Run first URL automation
run_first_url

# Then open the second URL
run_second_url
