# dotfiles

Мої особисті конфіги для Fedora Linux на ThinkPad.

---

## 1. Підключити GitHub акаунт до терміналу

```bash
# Встановити git якщо нема
sudo dnf install git -y

# Вказати своє ім'я і пошту (як на GitHub)
git config --global user.name "твій нік"
git config --global user.email "твій емейл"

# Згенерувати SSH ключ
ssh-keygen -t ed25519 -C "твій емейл"
# Просто тисни Enter на всі питання

# Скопіювати публічний ключ
cat ~/.ssh/id_ed25519.pub
# Скопіюй весь вивід
```

Потім іди на https://github.com/settings/keys → **New SSH key** → встав ключ → збережи.

Перевір що все працює:
```bash
ssh -T git@github.com
# Має написати: Hi твій-нік! You've successfully authenticated
```

---

## 2. Встановити свій конфіг на новій машині

```bash
# Клонувати репо
git clone git@github.com:yurawoin/dotfiles_fedora_gnome.git ~/dotfiles

# Зайти в папку і запустити скрипт
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Скрипт сам встановить весь софт, теми, розширення і накине всі конфіги.

---

## Структура репо

```
dotfiles/
├── install.sh                # Головний скрипт автоматизації
├── extensions.txt            # Розширення VS Code
├── gnome_settings.dconf      # Налаштування GNOME (тачпад, миша, розширення)
├── .zshrc                    # Конфіг терміналу
├── vscode-settings.json      # Налаштування VS Code
├── vscode-keybindings.json   # Гарячі клавіші VS Code
├── nvim/                     # Конфіги Neovim
├── blackbox/                 # Конфіги терміналу BlackBox
└── qbittorrent/              # Конфіги qBittorrent
```
