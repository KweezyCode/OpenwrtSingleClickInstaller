# OpenWrt Single Click Installer

Универсальный динамический инсталлятор дополнительных пакетов (ZeroTier, Zapret и другие) и автонастройкой для OpenWrt-роутеров.

## Требования

- OpenWrt-роутер с поддержкой `apk` (24.10 и новее)
- Доступ в интернет

## Быстрый старт

1. Войдите в терминал роутера через SSH.

2. Выполните следующую команду для загрузки, распаковки и запуска инсталлятора:

```bash
wget -qO- https://raw.githubusercontent.com/KweezyCode/OpenwrtSingleClickInstaller/main/install.sh | sh
```  