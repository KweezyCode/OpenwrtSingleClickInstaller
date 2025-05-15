#!/bin/sh
set -e

# Обновляем apk и ставим необходимые утилиты
echo "Установка unzip..."
apk update
apk add --no-cache unzip

# Скачиваем и распаковываем репозиторий
echo "Скачивание и распаковка..."
cd /tmp
wget -qO main.zip https://github.com/KweezyCode/OpenwrtSingleClickInstaller/archive/refs/heads/main.zip
unzip -o main.zip

# Запускаем оригинальный инсталлятор
echo "Распаковка завершена. Запуск инсталлятора..."
cd OpenwrtSingleClickInstaller-main
chmod +x main.sh
./main.sh