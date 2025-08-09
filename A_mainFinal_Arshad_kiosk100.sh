#!/bin/bash
set -e

echo "🔧 Updating system & installing necessary packages..."
sudo apt update && sudo apt install -y \
  chromium-browser \
  x11-xserver-utils \
  dbus-x11 \
  lightdm \
  mate-desktop-environment-core

echo "👤 Creating 'sdckiosk_final' user..."
if ! id "sdckiosk_final" &>/dev/null; then
  sudo adduser --disabled-password --gecos "" sdckiosk_final
  echo "sdckiosk_final:123" | sudo chpasswd   # Set password to 123
else
  echo "✅ User 'sdckiosk_final' already exists — resetting password to 123."
  echo "sdckiosk_final:123" | sudo chpasswd
fi

echo "🔐 Enabling auto-login for 'sdckiosk_final' in LightDM..."
sudo bash -c 'cat > /etc/lightdm/lightdm.conf' <<EOF
[Seat:*]
autologin-user=sdckiosk_final
autologin-user-timeout=0
user-session=mate
EOF

echo "📁 Creating kiosk script directory..."
sudo -u sdckiosk_final mkdir -p /home/sdckiosk_final/kiosk-html /home/sdckiosk_final/.config/autostart

# Create auto_main_kiosk.sh script
cat <<'EOF' | sudo tee /home/sdckiosk_final/kiosk-html/auto_main_kiosk.sh >/dev/null
#!/bin/bash

# Function to install required packages
install_dependencies() {
  echo "🔍 Checking and installing required packages..."
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
  run_website_2
  echo "🛑 Closing Chrome after automation on website 1..."
  kill $CHROME_PID
  sleep 3
}

run_website_2() {
  echo "🌐 Opening website 2: $WEBSITE_2_URL"
  google-chrome --new-window --start-fullscreen "$WEBSITE_2_URL" &
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

# ===== Main Execution =====
install_dependencies
install_chrome_if_missing
run_website_0
run_website_1
EOF

# Make script executable
sudo chmod +x /home/sdckiosk_final/kiosk-html/auto_main_kiosk.sh

# Create autostart entry to run the kiosk script
cat <<EOF | sudo tee /home/sdckiosk_final/.config/autostart/kiosk.desktop >/dev/null
[Desktop Entry]
Type=Application
Name=Kiosk
Exec=bash -c "xset s off -dpms && /home/sdckiosk_final/kiosk-html/auto_main_kiosk.sh"
X-GNOME-Autostart-enabled=true
EOF

sudo chown -R sdckiosk_final:sdckiosk_final /home/sdckiosk_final/

echo "💤 Disabling power-saving and screensaver for MATE..."
sudo -u sdckiosk_final dbus-launch gsettings set org.mate.power-manager sleep-display-ac 0
sudo -u sdckiosk_final dbus-launch gsettings set org.mate.power-manager sleep-display-battery 0
sudo -u sdckiosk_final dbus-launch gsettings set org.mate.screensaver idle-activation-enabled false
sudo -u sdckiosk_final dbus-launch gsettings set org.mate.screensaver lock-enabled false

# adding for removing the password arshad
# Set password for the user
echo "sdckiosk_final:123" | sudo chpasswd

# Unlock and set keyring password to empty so no prompt appears
sudo -u sdckiosk_final mkdir -p /home/sdckiosk_final/.local/share/keyrings
cat <<EOF | sudo -u sdckiosk_final tee /home/sdckiosk_final/.local/share/keyrings/login.keyring >/dev/null
[Keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=$(date +%s)
lock-on-idle=false
lock-after=false
use-lock-screen=false
EOF


# or else try this both 

sudo apt remove gnome-keyring -y

echo "✅ Kiosk setup completed successfully for Ubuntu MATE!"
echo "🔁 Rebooting system now..."
sudo reboot
