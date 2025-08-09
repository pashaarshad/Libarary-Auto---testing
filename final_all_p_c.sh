#!/bin/bash

# Function to install required packages
install_dependencies() {
  echo "🔍 Checking and installing required packages..."

  # List of required packages
  REQUIRED_PACKAGES=("xdotool" "wget" "gnupg" "software-properties-common")

  for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
      echo "📦 Installing $package..."
      sudo apt update
      sudo apt install -y "$package"
    else
      echo "✅ $package is already installed."
    fi
  done
}

# Function to install Google Chrome if not installed
install_chrome_if_missing() {
  if ! command -v google-chrome >/dev/null 2>&1; then
    echo "🚫 Google Chrome is not installed. Installing..."

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
    sudo apt install -y /tmp/chrome.deb

    # Clean up
    rm /tmp/chrome.deb

    if command -v google-chrome >/dev/null 2>&1; then
      echo "✅ Google Chrome successfully installed."
    else
      echo "❌ Failed to install Google Chrome. Exiting."
      exit 1
    fi
  else
    echo "✅ Google Chrome is already installed."
  fi
}

# Website URLs
WEBSITE_0_URL="https://sdclibary.netlify.app/"
WEBSITE_1_URL="https://mycampuz.co.in/visitor"
WEBSITE_2_URL="https://mycampuz.co.in/visitor/#/visitor"

run_website_0() {
  echo "🌐 Opening website 0: $WEBSITE_0_URL"
  google-chrome --start-fullscreen "$WEBSITE_0_URL" &
  CHROME_PID=$!
  sleep 20
  echo "🛑 Closing Chrome after 20 seconds on website 0..."
  kill $CHROME_PID
  sleep 3
}

run_website_1() {
  echo "🌐 Opening website 1: $WEBSITE_1_URL and automating input..."
  google-chrome --start-fullscreen "$WEBSITE_1_URL" &
  CHROME_PID=$!
  sleep 5

  CHROME_WIN_ID=$(xdotool search --onlyvisible --class "chrome" | head -n 1)

  echo "⏳ Waiting for 10 seconds before typing on website 1..."
  for i in {10..1}; do
      echo "$i..."
      sleep 1
  done

  xdotool windowactivate "$CHROME_WIN_ID"
  sleep 1

  xdotool mousemove --window "$CHROME_WIN_ID" 300 300 click 1
  sleep 0.5

  xdotool key Tab
  sleep 0.3
  xdotool type "123"
  sleep 0.3
  xdotool key Return

  sleep 4

  echo "🛑 Closing Chrome after automation on website 1..."
  kill $CHROME_PID
  sleep 3
}

run_website_2() {
  echo "🌐 Opening website 2: $WEBSITE_2_URL"
  google-chrome --start-fullscreen "$WEBSITE_2_URL" &
  CHROME_PID=$!
  sleep 5

  CHROME_WIN_ID=$(xdotool search --onlyvisible --class "chrome" | head -n 1)
  xdotool windowactivate "$CHROME_WIN_ID"

  echo "🔄 Starting infinite reload every 3 seconds..."

  while true; do
    xdotool key --window "$CHROME_WIN_ID" ctrl+r
    sleep 3
  done
}

# ===== Main Execution Starts Here =====

# Install all necessary tools first
install_dependencies
install_chrome_if_missing

# Then run the websites in order
run_website_0
run_website_1
run_website_2
