#!/bin/bash

SSH_KEY_DIR="./ssh-keys"
SSH_KEY_PATH="$SSH_KEY_DIR/id_rsa"
SSH_PUB_PATH="$SSH_KEY_DIR/id_rsa.pub"
AUTH_KEYS_PATH="$SSH_KEY_DIR/authorized_keys"

# Функция для создания ключей
create_keys() {
    echo "🔑 Создание SSH ключей на хосте..."
    mkdir -p "$SSH_KEY_DIR"
    
    if [ ! -f "$SSH_KEY_PATH" ]; then
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -q
        echo "✅ Ключи созданы: $SSH_KEY_DIR/"
    else
        echo "✅ Ключи уже существуют"
    fi
    
    # Создаем authorized_keys если нет
    if [ ! -f "$AUTH_KEYS_PATH" ]; then
        cat "$SSH_PUB_PATH" > "$AUTH_KEYS_PATH"
        echo "✅ authorized_keys создан"
    fi
    
    # Устанавливаем правильные права
    chmod 700 "$SSH_KEY_DIR"
    chmod 600 "$SSH_KEY_PATH"
    chmod 644 "$SSH_PUB_PATH"
    chmod 600 "$AUTH_KEYS_PATH"
}

# Функция для показа публичного ключа
show_key() {
    if [ -f "$SSH_PUB_PATH" ]; then
        echo "📋 Публичный ключ для Forgejo:"
        echo "========================================="
        cat "$SSH_PUB_PATH"
        echo "========================================="
    else
        echo "❌ Ключи не найдены. Запустите: $0 create"
    fi
}

# Функция для проверки подключения
test_connection() {
    echo "🔍 Проверка подключения к контейнеру..."
    if docker ps | grep -q vscode-remote-dev; then
        ssh -p 2222 -o StrictHostKeyChecking=no developer@localhost 'echo "✅ Подключение работает!"' 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✅ SSH подключение успешно!"
        else
            echo "❌ Ошибка подключения. Проверьте:"
            echo "  1. Контейнер запущен: docker ps"
            echo "  2. Права на ключи: ls -la ./ssh-keys/"
        fi
    else
        echo "❌ Контейнер не запущен. Запустите: docker compose up -d"
    fi
}

# Функция для синхронизации ключей с контейнером
sync_keys() {
    echo "🔄 Синхронизация ключей с контейнером..."
    if docker ps | grep -q vscode-remote-dev; then
        # Устанавливаем правильного владельца в контейнере
        docker exec vscode-remote-dev bash -c "chown -R developer:developer /home/developer/.ssh"
        docker exec vscode-remote-dev bash -c "chmod 700 /home/developer/.ssh && chmod 600 /home/developer/.ssh/*"
        echo "✅ Права синхронизированы"
    else
        echo "⚠️  Контейнер не запущен. Запустите: docker compose up -d"
    fi
}

# Команды
case "$1" in
    create)
        create_keys
        ;;
    show)
        show_key
        ;;
    test)
        test_connection
        ;;
    sync)
        sync_keys
        ;;
    rebuild)
        echo "🔄 Полная переустановка..."
        docker compose down
        rm -rf "$SSH_KEY_DIR"
        create_keys
        docker compose up -d
        sleep 3
        sync_keys
        test_connection
        ;;
    *)
        echo "Использование: $0 {create|show|test|sync|rebuild}"
        echo ""
        echo "  create  - Создать SSH ключи на хосте"
        echo "  show    - Показать публичный ключ для Forgejo"
        echo "  test    - Проверить SSH подключение"
        echo "  sync    - Синхронизировать права в контейнере"
        echo "  rebuild - Полная переустановка (удаляет старые ключи!)"
        exit 1
        ;;
esac