#!/bin/sh
set -e  # выходим при любом не-0 статусе

install_adguard_home() {
    echo "Установка AdGuard Home..."
    apk update
    apk add adguardhome

    echo "Включаем автозапуск и старт службы adguardhome..."
    service adguardhome enable
    service adguardhome start

    echo "Настройка dnsmasq для работы с AdGuard Home..."

    NET_ADDR=$(/sbin/ip -o -4 addr list br-lan | awk 'NR==1{ split($4, ip, "/"); print ip[1]; exit }')
    NET_ADDR6=$(/sbin/ip -o -6 addr list br-lan scope global | awk 'NR==1{ split($4, ip, "/"); print ip[1]; exit }')

    uci set dhcp.@dnsmasq[0].port="54"
    uci set dhcp.@dnsmasq[0].domain="lan"
    uci set dhcp.@dnsmasq[0].local="/lan/"
    uci set dhcp.@dnsmasq[0].expandhosts="1"
    uci set dhcp.@dnsmasq[0].cachesize="0"
    uci set dhcp.@dnsmasq[0].noresolv="1"
    uci -q del_list dhcp.@dnsmasq[0].server || true

    # Удаляем старые опции DNS/DHCP
    echo "Удаление старых опций DNS и DHCP..."
    uci -q del dhcp.lan.dhcp_option || true
    uci -q del dhcp.lan.dns || true

    echo "Настройка DHCP опций..."
    # DHCP option 3: шлюз
    uci add_list dhcp.lan.dhcp_option="3,${NET_ADDR}"
    # DHCP option 6: DNS
    uci add_list dhcp.lan.dhcp_option="6,${NET_ADDR}"
    # DHCP option 15: доменная суффикс
    uci add_list dhcp.lan.dhcp_option="15,lan"
    # IPv6 DNS
    uci add_list dhcp.lan.dns="${NET_ADDR6}"

    uci commit dhcp

    echo "Перезапуск dnsmasq и odhcpd..."
    service dnsmasq restart
    service odhcpd restart

    echo "AdGuard Home успешно установлен и настроен."
    echo "Web UI по умолчанию: http://${NET_ADDR}:3000/"
    echo "После первого запуска настройте в интерфейсе порты и рабочий каталог."
}

install_adguard_home "$@"
exit 0