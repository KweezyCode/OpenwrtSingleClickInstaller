#!/bin/sh
# Универсальный динамический инсталлятор

SCRIPTS_DIR="$(dirname "$0")/installers"

# Собираем список установщиков
scripts=()
for f in "$SCRIPTS_DIR"/install_*.sh; do
  [ -f "$f" ] && scripts+=( "$f" )
done

# Если нет ни одного инсталлятора — выходим
[ "${#scripts[@]}" -gt 0 ] || { echo "Не найдено ни одного install_*.sh в $SCRIPTS_DIR"; exit 1; }

while :; do
  echo
  echo "Выберите программное обеспечение для установки:"
  for i in "${!scripts[@]}"; do
    name="$(basename "${scripts[$i]}" .sh)"
    name="${name#install_}"
    printf " %2d) %s\n" $((i+1)) "$name"
  done
  echo "  0) Выход"

  read -p "Введите номер: " choice

  case "$choice" in
    0)  echo "Выход."; exit 0 ;;
    ''|*[!0-9]*) echo "Неверный ввод." ; continue ;;
    *)
      idx=$((choice-1))
      if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#scripts[@]}" ]; then
        echo "Неверный выбор."; continue
      fi
      pkg="$(basename "${scripts[$idx]}" .sh)"
      pkg="${pkg#install_}"
      read -p "Установить $pkg? (y/n): " ans
      case "$ans" in
        y|Y)
          [ -x "${scripts[$idx]}" ] || chmod +x "${scripts[$idx]}"
            echo "Запуск установки $pkg..."
          "${scripts[$idx]}"  \
            || { echo "Ошибка при установке $pkg. Выходим."; exit 1; }
          ;;
        *) echo "Отмена установки $pkg." ;;
      esac
      ;;
  esac
done