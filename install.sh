#!/usr/bin/env bash
# Ставить оновлювач Proton: ярлик у меню + таймер (кожні 30 хв: застосувати відкладене, раз на 12 год перевірити).
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
Name=Оновлювач Proton
Comment=Автооновлення GE-Proton / proton-rtsp для ігор Steam
Exec=$HOME/.local/bin/proton-updater-gui
Icon=system-software-update
Categories=Game;Utility;
EOW
cat > ~/.config/systemd/user/proton-updater.service <<EOW
[Unit]
Description=Оновлювач Proton
[Service]
Type=oneshot
ExecStart=$HOME/.local/bin/proton-updater run
EOW
cat > ~/.config/systemd/user/proton-updater.timer <<EOW
[Unit]
Description=Оновлювач Proton — кожні 30 хв
[Timer]
OnBootSec=3min
OnUnitActiveSec=30min
Persistent=true
[Install]
WantedBy=timers.target
EOW
systemctl --user daemon-reload
systemctl --user enable --now proton-updater.timer
echo "Встановлено."
