#!/bin/sh
# Универсальный динамический инсталлятор для OpenWrt (ash-совместимо)

SCRIPTS_DIR="$(dirname "$0")/installers"

# Собираем список установщиков (Posix-совместимо, без массивов)
tmp=""
for f in "$SCRIPTS_DIR"/install_*.sh; do
  [ -f "$f" ] && tmp="$tmp \"$f\""
done
eval "set -- $tmp"

# Если нет ни одного инсталлятора — выходим
[ "$#" -gt 0 ] || {
  echo "Не найдено ни одного install_*.sh в $SCRIPTS_DIR"
  exit 1
}

while :; do
  echo
  echo "Выберите программное обеспечение для установки:"
  i=1
  for f in "$@"; do
    name="$(basename "$f" .sh)"
    name="${name#install_}"
    printf " %2d) %s\n" "$i" "$name"
    i=$((i+1))
  done
  echo "  0) Выход"

  printf "Введите номер: "
  read choice

  case "$choice" in
    0)
      echo "Выход."
      exit 0
      ;;
    ''|*[!0-9]*)
      echo "Неверный ввод: $choice"
      continue
      ;;
    *)
      # Проверяем диапазон
      if [ "$choice" -lt 1 ] || [ "$choice" -gt "$#" ]; then
        echo "$choice не является допустимым номером."
        continue
      fi

      # Получаем путь к выбранному скрипту
      i=1
      for f in "$@"; do
        [ "$i" -eq "$choice" ] && script="$f" && break
        i=$((i+1))
      done

      pkg="$(basename "$script" .sh)"
      pkg="${pkg#install_}"
      printf "Установить %s? (y/n): " "$pkg"
      read ans
      case "$ans" in
        y|Y)
          [ -x "$script" ] || chmod +x "$script"
          echo "Запуск установки $pkg..."
          "$script" || {
            echo "Ошибка при установке $pkg. Выходим."
            exit 1
          }
          ;;
        *)
          echo "Отмена установки $pkg."
          ;;
      esac
      ;;
  esac
done