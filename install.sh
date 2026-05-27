#!/bin/bash
set -e

DOTFILES_DIR="$(pwd)"
mkdir -p "$HOME/.config"

echo "🚀 Починаємо повний фарш для твого нового ThinkPad..."

# 1. Системний софт через DNF
sudo dnf update -y
sudo dnf install -y zsh neovim git curl fzf ripgrep flatpak sqlite dconf unzip python3-pip

# 2. Встановлення GUI додатків через Flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.brave.Browser \
                           com.raggesilver.BlackBox \
                           com.visualstudio.code \
                           org.telegram.desktop \
                           org.qbittorrent.qBittorrent \
                           com.valvesoftware.Steam \
                           com.discordapp.Discord

# 3. Чистий Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting 2>/dev/null || true

# 4. GNOME розширення через gnome-extensions-cli (надійніше ніж curl+grep)
echo "🧩 Ставимо розширення GNOME Shell..."
pip install gnome-extensions-cli --user --quiet
export PATH="$HOME/.local/bin:$PATH"

gext install bluetooth-battery-meter@maniacx.github.io 2>/dev/null || true
gext install blur-my-shell@aunetx 2>/dev/null || true
gext install dash-to-dock-animated@fthx 2>/dev/null || true
gext install just-perfection-desktop@just-perfection 2>/dev/null || true
gext install user-avatar-in-quick-settings@fedi.biz 2>/dev/null || true

# 5. Тема WhiteSur
mkdir -p "$HOME/.themes" "$HOME/.icons"
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/whitesur-gtk 2>/dev/null || true
cd /tmp/whitesur-gtk && ./install.sh -t all -N glass -i fedora && cd "$DOTFILES_DIR"
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/whitesur-icon 2>/dev/null || true
cd /tmp/whitesur-icon && ./install.sh && cd "$DOTFILES_DIR"

# 6. SQLiteStudio
if [ ! -d "$HOME/SQLiteStudio" ]; then
    curl -L "https://sqlitestudio.pl/files/free/stable/linux64/sqlitestudio-3.4.4.tar.xz" -o /tmp/sqlitestudio.tar.xz
    tar -xf /tmp/sqlitestudio.tar.xz -C "$HOME/"
fi

# 7. НАКАТ ТВОЇХ КОНФІГІВ (Символічні лінки)
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
rm -rf "$HOME/.config/nvim"       && ln -sfn "$DOTFILES_DIR/nvim"        "$HOME/.config/nvim"
rm -rf "$HOME/.config/blackbox"   && ln -sfn "$DOTFILES_DIR/blackbox"    "$HOME/.config/blackbox"
rm -rf "$HOME/.config/qBittorrent" && ln -sfn "$DOTFILES_DIR/qbittorrent" "$HOME/.config/qBittorrent"

# 8. Налаштування та розширення VS Code
# VS Code встановлено через Flatpak, тому використовуємо flatpak run
mkdir -p "$HOME/.var/app/com.visualstudio.code/config/Code/User"
ln -sf "$DOTFILES_DIR/vscode-settings.json"    "$HOME/.var/app/com.visualstudio.code/config/Code/User/settings.json"
ln -sf "$DOTFILES_DIR/vscode-keybindings.json" "$HOME/.var/app/com.visualstudio.code/config/Code/User/keybindings.json"

if [ -f "$DOTFILES_DIR/extensions.txt" ]; then
    echo "Ставимо розширення VS Code..."
    while read -r ext; do
        flatpak run com.visualstudio.code --install-extension "$ext" --force 2>/dev/null || true
    done < "$DOTFILES_DIR/extensions.txt"
fi

# 9. Імпорт налаштувань GNOME (тачпад, миша, теми, розширення)
if [ -f "$DOTFILES_DIR/gnome_settings.dconf" ]; then
    echo "⚙️ Накочуємо налаштування системи й тачпада..."
    dconf load /org/gnome/ < "$DOTFILES_DIR/gnome_settings.dconf"
fi

# 10. Старт Neovim (Lazy.nvim сам все викачає)
nvim --headless "+Lazy! sync" +qa

# 11. Встановлюємо zsh як дефолтний шелл
chsh -s "$(which zsh)"

echo "😎 Брат, повний фарш готовий! Все налетіло як рідне, перезавантаж систему!"
