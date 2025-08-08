#!/bin/bash

set -e

echo "➡️ Creating user 'kiosk' with no password..."
if id -u kiosk &>/dev/null; then
  echo "User kiosk already exists."
else
  adduser --disabled-password --gecos "" kiosk
fi

echo "➡️ Installing required packages..."
apt update
apt install -y wget gnupg2 curl xdotool

if ! command -v google-chrome &>/dev/null; then
  echo "➡️ Installing Google Chrome..."
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
  apt install -y /tmp/chrome.deb
  rm /tmp/chrome.deb
else
  echo "Google Chrome already installed."
fi

echo "➡️ Creating automation script for kiosk user..."

sudo -u kiosk mkdir -p /home/kiosk

cat > /home/kiosk/full_automation.sh <<'EOF'
#!/bin/bash

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

  echo "🔄 Starting infinite reload every 2 seconds..."

  while true; do
    xdotool key --window "$CHROME_WIN_ID" ctrl+r
    sleep 2
  done
}

run_website_0
run_website_1
run_website_2
EOF

chown kiosk:kiosk /home/kiosk/full_automation.sh
chmod +x /home/kiosk/full_automation.sh

echo "➡️ Setting up LightDM auto-login for kiosk user..."
cat > /etc/lightdm/lightdm.conf <<EOF
[Seat:*]
autologin-user=kiosk
autologin-user-timeout=0
user-session=ubuntu
EOF

echo "➡️ Creating autostart entry for automation script..."
sudo -u kiosk mkdir -p /home/kiosk/.config/autostart
cat > /home/kiosk/.config/autostart/full_automation.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Full Automation Script
Exec=/home/kiosk/full_automation.sh
X-GNOME-Autostart-enabled=true
NoDisplay=false
EOF

echo "✅ Setup complete! Reboot the system to start auto-login and automation."
