Collecting workspace information```markdown
# OpenWrt Single Click Installer

Универсальный динамический инсталлятор дополнительных пакетов (ZeroTier, Zapret и другие) и автонастройкой для OpenWrt-роутеров.

## Требования

- OpenWrt-роутер с поддержкой `apk` (24.10 и новее)
- Доступ в интернет

## Быстрый старт

1. Войдите в терминал роутера через SSH.

2. Выполните следующую команду для установки и запуска инсталлятора:

```bash
apk update \
&& apk add --no-cache git-http \
&& cd /tmp && git clone https://github.com/KweezyCode/OpenwrtSingleClickInstaller.git \
&& cd OpenwrtSingleClickInstaller \
&& chmod +x install.sh \
&& ./install.sh
```