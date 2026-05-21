#!/bin/bash
echo "🚀 Настройка окружения для VS Code Remote-SSH"

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен"
    exit 1
fi

# Создание структуры
mkdir -p .devcontainer docker

# Копирование файлов (предполагается, что они рядом)
cp docker/Dockerfile docker/
cp docker/ssh-setup.sh docker/
cp .devcontainer/devcontainer.json .devcontainer/

# Создание .env
if [ ! -f .env ]; then
    cat > .env << EOF
DEV_USER=developer
DEV_UID=$(id -u)
DEV_GID=$(id -g)
GIT_AUTHOR_NAME="$(git config user.name)"
GIT_AUTHOR_EMAIL="$(git config user.email)"
FORGEJO_URL=http://host.docker.internal:3000
EOF
    echo "✅ Создан .env файл"
fi

# Запуск
make build && make up

echo "✅ Готово!"
echo "📝 Публичный SSH ключ для Forgejo:"
docker exec vscode-remote-dev cat /home/developer/.ssh/id_rsa.pub
