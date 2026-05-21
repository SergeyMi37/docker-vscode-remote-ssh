# VS Code Remote-SSH Development Environment

Готовое окружение для разработки с AI-агентами, Git и доступом к Forgejo.

## Быстрый старт

### 1. Клонирование и настройка

```bash
git clone https://github.com/yourusername/vscode-remote-dev.git
cd vscode-remote-dev
cp env.example .env
# Отредактируйте .env: укажите ваше имя, email
```

### 2. Сборка и запуск

```bash
make build
make up
```

### 3. Настройка SSH-ключа для Forgejo

```bash
# Получите публичный ключ из контейнера
make shell
cat ~/.ssh/id_rsa.pub
# Скопируйте вывод и добавьте в Forgejo: Settings > SSH Keys
exit
```

### 4. Подключение через VS Code

1. Установите расширение **Remote - SSH**
2. Нажмите F1 → Remote-SSH: Add New SSH Host
3. Введите: `ssh developer@localhost -p 2222`
4. Файл конфигурации: `~/.ssh/config`
5. Нажмите F1 → Remote-SSH: Connect to Host
6. Выберите localhost:2222

Новое окно VS Code подключено к контейнеру!

## Работа с Forgejo

### Клонирование через SSH

В терминале VS Code (уже внутри контейнера):

```bash
git clone git@your-forgejo.com:username/repo.git
```

### Клонирование через HTTP с токеном

```bash
git clone http://your-forgejo.com/username/repo.git
# Используйте токен как пароль
```

### Настройка Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Интеграция с AI

### GitHub Copilot

1. Установите расширение GitHub Copilot
2. Войдите в аккаунт GitHub
3. Работайте с AI прямо в контейнере

### Чат с AI

Расширения уже установлены в `.devcontainer/devcontainer.json`:

- GitHub Copilot Chat
- GitLens (для анализа кода)

## Полезные команды

```bash
# В контейнере
python --version    # Python 3.10+
node --version      # Node.js
git --version       # Git
uv --version        # Быстрый pip

# Работа с Git
git status
git log --oneline --graph

# Работа с кодом
# В VS Code: Ctrl+P > @ для поиска символов
# Ctrl+Shift+P для команд
```

## Устранение проблем

### Ошибка "Permission denied (publickey)"

- Проверьте, что ключ добавлен в Forgejo
- Проверьте подключение: `ssh -T git@your-forgejo.com`
- Используйте HTTP вместо SSH: `git clone http://...`

### Не подключается VS Code

- Проверьте, что контейнер запущен: `make status`
- Проверьте порт: `netstat -an | grep 2222`
- Перезапустите: `make down && make up`

### Docker не работает внутри контейнера

Удалите комментарий с volumes в `docker-compose.yml`:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### Ошибка прав доступа к папке

```bash
# В контейнере
sudo chown -R developer:developer /workspace
git config --global --add safe.directory /workspace/*
```

## Дополнительные настройки

### Для Windows (WSL2)

- Установите Docker Desktop с WSL2 backend
- В `.env` добавьте: `FORGEJO_URL=http://localhost:3000`
- Запускайте команды из WSL2 терминала

### Для работы с несколькими проектами

```bash
# Создайте копию .env для каждого проекта
cp .env .env.project1
docker-compose --env-file .env.project1 up -d
```

## Безопасность

- Контейнер изолирован от хостовой системы
- SSH работает только на localhost:2222
- Все ключи хранятся внутри контейнера
- Для Forgejo используйте отдельные токены доступа
