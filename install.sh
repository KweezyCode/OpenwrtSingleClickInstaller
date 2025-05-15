#!/bin/sh
# Универсальный скрипт для установки софта на OpenWrt

# Пример функций установки программного обеспечения
install_package1() {
    echo "Установка софта Package1..."
    # здесь размещается логика установки Package1
    # например: opkg update && opkg install package1
}

install_package2() {
    echo "Установка софта Package2..."
    # здесь размещается логика установки Package2
    # например: opkg update && opkg install package2
}

# Можно добавить и другие функции установки по необходимости

# Основное меню скрипта
echo "Выберите программное обеспечение для установки:"
echo "1) Package1"
echo "2) Package2"
echo "3) Выход"

read -p "Введите номер выбранного программного обеспечения: " choice

case "$choice" in
    1)
        read -p "Вы уверены, что хотите установить Package1? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            install_package1
        else
            echo "Отмена установки Package1."
        fi
        ;;
    2)
        read -p "Вы уверены, что хотите установить Package2? (y/n): " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            install_package2
        else
            echo "Отмена установки Package2."
        fi
        ;;
    3)
        echo "Выход из скрипта."
        exit 0
        ;;
    *)
        echo "Неверный выбор. Завершение работы скрипта."
        exit 1
        ;;
esac
