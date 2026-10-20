#!/usr/bin/env bash
# Installs Proton Updater: menu entry + timer (every 30 min: apply pending, check for new versions every 12 h).
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.local/bin ~/.local/share/applications ~/.config/systemd/user
cat > ~/.local/bin/proton-updater <<EOW
#!/usr/bin/env bash
cd "$D"
exec python3 protonupd.py "\$@"
EOW
cat > ~/.local/bin/proton-updater-gui <<EOW
#!/usr/bin/env bash
cd "$D"
exec python3 protonupd_gui.py "\$@"
EOW
chmod +x ~/.local/bin/proton-updater ~/.local/bin/proton-updater-gui
cat > ~/.local/share/applications/proton-updater.desktop <<EOW
[Desktop Entry]
Type=Application
Name=Proton Updater
Name[uk]=Оновлювач Proton
Comment=Auto-update GE-Proton / proton-rtsp for Steam games
Comment[uk]=Автооновлення GE-Proton / proton-rtsp для ігор Steam
Exec=$HOME/.local/bin/proton-updater-gui
Icon=system-software-update
Categories=Game;Utility;
EOW
cat > ~/.config/systemd/user/proton-updater.service <<EOW
[Unit]
Description=Proton Updater
[Service]
Type=oneshot
ExecStart=$HOME/.local/bin/proton-updater run
EOW
cat > ~/.config/systemd/user/proton-updater.timer <<EOW
[Unit]
Description=Proton Updater — every 30 min
[Timer]
OnBootSec=3min
OnUnitActiveSec=30min
Persistent=true
[Install]
WantedBy=timers.target
EOW
systemctl --user daemon-reload
systemctl --user enable --now proton-updater.timer
echo "Installed."
