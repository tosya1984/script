# Використовуємо легкий образ Alpine Linux
FROM alpine:latest

# Встановлюємо Git
RUN apk add --no-cache git bash

# Створюємо каталог /app
WORKDIR /app

# Копіюємо файли script.sh та nginx.log у контейнер
COPY script.sh nginx.log /app/

# Виправляємо можливі проблеми з кодуванням
RUN dos2unix /app/script.sh || true

# Робимо script.sh виконуваним
RUN chmod +x /app/script.sh

# Налаштовуємо Git (користувач, email, основна гілка)
RUN git config --global user.name "AntonTsiatska" && \
    git config --global user.email "anton@tsiatska.com" && \
    git config --global init.defaultBranch main

# Виконуємо script.sh та залишаємо контейнер працюючим
CMD ["/bin/sh", "-c", "/app/script.sh; exec /bin/bash"]

