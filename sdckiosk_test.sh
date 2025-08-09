#!/bin/bash
# =========================================
# Ubuntu Kiosk Auto-Setup for sdckiosk user
# =========================================

# 1. Create the new user 'sdckiosk' with password '123'
echo "👤 Creating user 'sdckiosk'..."
if id "sdckiosk" &>/dev/null; then
    echo "✅ User 'sdckiosk' already exists."
else
    sudo adduser --gecos "" --disabled-password sdckiosk
    echo "sdckiosk:123" | sudo chpasswd
    echo "✅ User 'sdckiosk' created with password '123'."
fi

# 2. Add 'sdckiosk' to sudo group and disable sudo password
echo "🛠 Giving 'sdckiosk' passwordless sudo..."
sudo usermod -aG sudo sdckiosk
if ! sudo grep -q "^sdckiosk ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
    echo "sdckiosk ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

# 3. Enable auto-login for 'sdckiosk'
echo "🔄 Enabling auto-login..."
AUTOLOGIN_CONF="/etc/gdm3/custom.conf"
if [ -f "$AUTOLOGIN_CONF" ]; then
    sudo sed -i 's/^#\?AutomaticLoginEnable.*/AutomaticLoginEnable=true/' "$AUTOLOGIN_CONF"
    sudo sed -i 's/^#\?AutomaticLogin.*/AutomaticLogin=sdckiosk/' "$AUTOLOGIN_CONF"
else
    echo "⚠ Could not find $AUTOLOGIN_CONF — you may be using LightDM."
    # For LightDM
    if [ -f "/etc/lightdm/lightdm.conf" ]; then
        sudo bash -c 'cat > /etc/lightdm/lightdm.conf <<EOF
[Seat:*]
autologin-user=sdckiosk
autologin-user-timeout=0
EOF'
    fi
fi

# 4. Create the kiosk script in sdckiosk's home
echo "📄 Installing kiosk script..."
KIOSK_SCRIPT="/home/sdckiosk/kiosk.sh"
sudo tee "$KIOSK_SCRIPT" > /dev/null <<'EOF'
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

# Run setup
install_dependencies
install_chrome_if_missing
run_website_0
run_website_1
EOF

sudo chmod +x "$KIOSK_SCRIPT"
sudo chown sdckiosk:sdckiosk "$KIOSK_SCRIPT"

# 5. Auto-run kiosk script on login
echo "⚡ Setting kiosk script to run on login..."
AUTOSTART_DIR="/home/sdckiosk/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
sudo tee "$AUTOSTART_DIR/kiosk.desktop" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=/home/sdckiosk/kiosk.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Kiosk Script
EOF
sudo chown -R sdckiosk:sdckiosk "$AUTOSTART_DIR"

echo "✅ Setup complete! Reboot to test."
