#!/bin/bash
# Скрипт настройки Git с токеном Forgejo

GIT_TOKEN="${FORGEJO_TOKEN}"
GIT_USER="${FORGEJO_USERNAME:-dev}"
GIT_URL="${FORGEJO_URL:-http://localhost:3000}"
GIT_EMAIL="${GIT_AUTHOR_EMAIL}"
GIT_NAME="${GIT_AUTHOR_NAME}"

if [ -n "$GIT_TOKEN" ]; then
    echo "🔑 Настройка Git с токеном Forgejo..."
    
    # Настройка Git credentials
    git config --global credential.helper store
    
    # Сохранение токена для текущего URL
    echo "${GIT_URL}" | sed "s|http://|http://${GIT_USER}:${GIT_TOKEN}@|" >> ~/.git-credentials
    
    # Настройка user
    if [ -n "$GIT_NAME" ]; then
        git config --global user.name "$GIT_NAME"
    fi
    
    if [ -n "$GIT_EMAIL" ]; then
        git config --global user.email "$GIT_EMAIL"
    fi
    
    echo "✅ Git настроен с токеном для ${GIT_URL}"
else
    echo "⚠️  FORGEJO_TOKEN не установлен. Push через HTTP будет требовать пароль."
fi

# Настройка для автоматического преобразования URL
git config --global url."http://${GIT_USER}@".insteadOf "http://"