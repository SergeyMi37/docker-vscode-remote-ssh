#!/bin/bash
# Скрипт для настройки SSH-ключа при первом запуске

USERNAME=${1:-developer}
SSH_DIR=/home/$USERNAME/.ssh

if [ ! -f $SSH_DIR/authorized_keys ]; then
    echo "========================================="
    echo "⚠️  SSH ключ не найден!"
    echo "========================================="
    echo "Чтобы добавить ключ, выполните:"
    echo "  docker exec -it dev-container cat $SSH_DIR/id_rsa.pub"
    echo "ИЛИ скопируйте ваш публичный ключ вручную:"
    echo "  docker cp ~/.ssh/id_rsa.pub dev-container:$SSH_DIR/authorized_keys"
    echo "========================================="
fi

# Генерация ключей, если их нет
if [ ! -f $SSH_DIR/id_rsa ]; then
    echo "Генерация SSH-ключа для разработчика..."
    sudo -u $USERNAME ssh-keygen -t ed25519 -C "developer@dev-container" -f $SSH_DIR/id_rsa -N ""
    echo "✅ SSH ключ создан: $SSH_DIR/id_rsa.pub"
    echo "Добавьте этот публичный ключ в ваш Forgejo:"
    cat $SSH_DIR/id_rsa.pub
fi
