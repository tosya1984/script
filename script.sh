#!/bin/bash

# Значення за замовченням
DEFAULT_LOG_FILE="nginx.log"
DEFAULT_OUTPUT_CSV="output.csv"
DEFAULT_PATH_CSV="./git/"

# Запитуємо користувача про вхідний файл
read -p "Введіть шлях до лог-файла (за замовченням: $DEFAULT_LOG_FILE): " LOG_FILE
LOG_FILE=${LOG_FILE:-$DEFAULT_LOG_FILE} # Якщо порожнє, використовуємо значення за замовченням

# Запитуємо користувача про вихідний файл
read -p "Введіть шлях до CSV-файла (за замовченням: $DEFAULT_OUTPUT_CSV): " OUTPUT_CSV
OUTPUT_CSV=${OUTPUT_CSV:-$DEFAULT_OUTPUT_CSV} # Якщо порожнє, використовуємо значення за замовченням

# Перевіряємо, чи існує вхідний файл
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Помилка: Файл $LOG_FILE не знайдено!"
    exit 1
fi

# Створюємо каталог для git-репозиторію
mkdir -p git

# Запитуємо користувача про стовпець для сортування
echo "Виберіть стовпець для сортування:"
echo "1. IP Address"
echo "2. Datetime"
echo "3. Method"
echo "4. URL"
echo "5. Status"
echo "6. Size"
read -p "Введіть номер стовпця (за замовченням: 1): " SORT_COLUMN
SORT_COLUMN=${SORT_COLUMN:-1}

# Запитуємо користувача про порядок сортування
read -p "Виберіть порядок сортування (asc/desc, за замовченням: asc): " SORT_ORDER
SORT_ORDER=${SORT_ORDER:-asc}

# Заголовок для CSV
echo "IP Address,Datetime,Method,URL,Status,Size" > "$DEFAULT_PATH_CSV$OUTPUT_CSV"

# Парсинг логів і запис у CSV
awk '{
    # Розбираємо стандартний формат логу Nginx
    match($0, /([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) - - \[([^]]+)\] "([A-Z]+) ([^ ]+) [^"]*" ([0-9]+) ([0-9]+)/, arr)
    if (arr[0] != "") {
        # Формуємо CSV-рядок
        printf "%s,\"%s\",%s,%s,%s,%s\n", arr[1], arr[2], arr[3], arr[4], arr[5], arr[6]
    }
}' "$LOG_FILE" >> "$OUTPUT_CSV.unsorted"

# Сортування CSV
if [[ "$SORT_ORDER" == "asc" ]]; then
    sort -t ',' -k"$SORT_COLUMN" "$OUTPUT_CSV.unsorted" >> "$DEFAULT_PATH_CSV$OUTPUT_CSV"
elif [[ "$SORT_ORDER" == "desc" ]]; then
    sort -t ',' -k"$SORT_COLUMN" -r "$OUTPUT_CSV.unsorted" >> "$DEFAULT_PATH_CSV$OUTPUT_CSV"
else
    echo "Помилка: Неправильний порядок сортування. Дані не будуть відсортовані."
    cat "$OUTPUT_CSV.unsorted" >> "$DEFAULT_PATH_CSV$OUTPUT_CSV"
fi

# Видаляємо тимчасовий файл
rm -f "$OUTPUT_CSV.unsorted"

echo "Лог файл $LOG_FILE успішно конвертовано у $DEFAULT_PATH_CSV$OUTPUT_CSV з сортуванням за стовпцем $SORT_COLUMN ($SORT_ORDER)"

# Перевіряємо, чи встановлений git
if ! command -v git &> /dev/null; then
    echo "Git не встановлено! Встановіть його перед виконанням скрипта."
    exit 1
fi

# Створюємо git репозиторій
cd "$DEFAULT_PATH_CSV" || { echo "❌ Помилка переходу в каталог $DEFAULT_PATH_CSV"; exit 1; }

if [ -d ".git" ]; then
    git add .
    git commit -m "Initial commit"
    echo "Файл доданий та створений новий коміт до існуючого репозиторію!"
else
    git init
    git add .
    git commit -m "Initial commit"
    echo "Git-репозиторій успішно створено! Файл доданий та створений новий коміт!"
fi


