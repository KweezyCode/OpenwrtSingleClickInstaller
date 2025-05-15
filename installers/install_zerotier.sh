#!/bin/sh
set -e  # выходим при любом не-0 статусе

install_zerotier() {
    echo "Установка ZeroTier..."
    apk update
    apk add zerotier
    
    if [ $? -ne 0 ]; then
        echo "Ошибка установки пакета zerotier"
        return 1
    fi

    echo "ZeroTier установлен."

    # Запрос 16-значного Network ID
    read -p "Введите 16-значный Network ID из Zerotier Central: " NETWORK_ID
    if [ -z "$NETWORK_ID" ]; then
        echo "Не указан Network ID. Завершение."
        return 1
    fi

    # Конфигурация для ZeroTier версии 1.14.1 и новее
    echo "Настройка ZeroTier для версии 1.14.1 (и новее)..."
    uci set zerotier.global.enabled='1'
    uci delete zerotier.earth 2>/dev/null

    uci set zerotier.mynet=network
    uci set zerotier.mynet.id="$NETWORK_ID"
    uci set zerotier.mynet.allow_managed='1'
    uci set zerotier.mynet.allow_global='0'
    uci set zerotier.mynet.allow_default='0'
    uci set zerotier.mynet.allow_dns='0'

    uci commit zerotier

    # Перезапускаем сервис Zerotier
    echo "Перезапуск службы zerotier..."
    service zerotier restart

    echo "Ожидание подключения к сети ZeroTier..."
    # Даем время Zerotier подключиться к сети и получить имя устройства (примерно 10 секунд)
    sleep 10

    # Получаем имя устройства по Network ID (например, ztXXXXXXXX)
    DEVICE=$(zerotier-cli listnetworks | grep "$NETWORK_ID" | awk '{for(i=1;i<=NF;i++){if($i ~ /^zt/){print $i; exit}}}')
    if [ -z "$DEVICE" ]; then
        echo "Не удалось получить имя ZeroTier интерфейса для сети $NETWORK_ID."
        echo "Попробуйте проверить статус через zerotier-cli listnetworks."
        return 1
    fi

    echo "Найден ZeroTier интерфейс: $DEVICE"

    # Настраиваем сетевой интерфейс в UCI
    echo "Настройка сетевого интерфейса ZeroTier..."
    uci -q delete network.ZeroTier
    uci set network.ZeroTier=interface
    uci set network.ZeroTier.proto='none'
    uci set network.ZeroTier.device="$DEVICE"
    uci commit network

    # Настройка Firewall
    echo "Настройка firewall для ZeroTier..."
    FIREWALL_ZONE_NAME="zerotier"

    # Добавляем зону, если она ещё не создана
    firewall_zone_exist=$(uci show firewall 2>/dev/null | grep "config firewall 'zone'" | grep "$FIREWALL_ZONE_NAME")
    if [ -z "$firewall_zone_exist" ]; then
        uci add firewall zone
        zone_index=$(uci get firewall.@zone[-1].name 2>/dev/null)
        uci set firewall.@zone[-1].name="$FIREWALL_ZONE_NAME"
        uci set firewall.@zone[-1].input='ACCEPT'
        uci set firewall.@zone[-1].output='ACCEPT'
        uci set firewall.@zone[-1].forward='ACCEPT'
        uci set firewall.@zone[-1].masq='1'
        # Привязываем новый интерфейс к зоне
        uci add_list firewall.@zone[-1].network='ZeroTier'
    else
        echo "Firewall зона \"$FIREWALL_ZONE_NAME\" уже существует."
    fi

    # Настраиваем правила переадресации для зоны zerotier
    echo "Настройка переадресаций (firewall forwarding)..."
    # Очистим уже существующие forwarding для зоны zerotier, чтобы избежать дубликатов
    uci -q delete firewall.@forwarding[0]

    uci add firewall forwarding
    uci set firewall.@forwarding[-1].src="$FIREWALL_ZONE_NAME"
    uci set firewall.@forwarding[-1].dest='lan'
    uci add firewall forwarding
    uci set firewall.@forwarding[-1].src="$FIREWALL_ZONE_NAME"
    uci set firewall.@forwarding[-1].dest='wan'
    uci add firewall forwarding
    uci set firewall.@forwarding[-1].src='lan'
    uci set firewall.@forwarding[-1].dest="$FIREWALL_ZONE_NAME"

    uci commit firewall

    echo "Перезапускаем firewall и сеть..."
    /etc/init.d/firewall restart
    /etc/init.d/network restart

    echo "Настройка ZeroTier завершена."
    echo "Проверьте статус устройства командой: zerotier-cli info"
    echo "После авторизации устройства в Zerotier Central устройство сможет полноценно подключаться к виртуальной сети."
}

install_zerotier "$@"