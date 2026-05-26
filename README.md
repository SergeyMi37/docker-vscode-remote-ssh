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
su - developer
cat ~/.ssh/id_rsa.pub

bash /usr/local/bin/ssh-setup.sh
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


### 5. Первоначальная настройка SSH-ключей

```bash
# 1. Создать ключи на хосте
make setup-keys
# или
./manage-ssh-keys.sh create

# 2. Показать ключ и добавить в Forgejo
make show-key
# Скопировать вывод и добавить в Forgejo: Settings > SSH Keys

# 3. Запустить контейнер
make up

# 4. Проверить подключение
make ssh
# или
./manage-ssh-keys.sh test

# 5. В VS Code подключиться
# F1 → Remote-SSH: Connect to Host → developer@localhost -p 2222
```

### 6. Проверка сохранения ключей

```bash
# После пересборки контейнера
docker compose down
docker compose up -d

# Ключи должны быть на месте
ls -la ./ssh-keys/
# id_rsa, id_rsa.pub, authorized_keys - все на месте

# Подключение должно работать без перегенерации
make ssh
```

---

## Работа с Docker: образы и контейнеры

### 📦 Основные понятия

| Понятие | Аналогия | Описание |
|---------|----------|----------|
| **Образ (Image)** | Чертёж / Штамп | Статичный "слепок" системы. Неизменяемый, хранится на диске |
| **Контейнер (Container)** | Готовый автомобиль | Запущенный экземпляр образа. Можно изменять, устанавливать ПО |
| **Dockerfile** | Инструкция | Рецепт сборки образа |

### Ключевые отличия

| Характеристика | Образ | Контейнер |
|----------------|-------|-----------|
| Живой/изменяемый | ❌ Нет | ✅ Да |
| Можно редактировать | ❌ Нельзя | ✅ Можно |
| Состояние | Статический | Динамический (RAM + процессы) |
| Можно запустить | ❌ Нельзя | ✅ Да (`docker start`) |
| Хранит изменения | ❌ Нет | ✅ Да |

---

### 💾 Сохранение работы (из контейнера в образ)

**Ситуация:** вы вручную установили ПО внутри контейнера

```bash
# 1. Посмотреть список контейнеров
docker ps -a

# 2. Сохранить изменения в новый образ
docker commit <CONTAINER_ID> my-saved-image:v1

# 3. Проверить, что образ создался
docker images | grep my-saved-image
```

#### Почему `commit`, а не `export`?

| Возможность | `docker commit` | `docker export` |
|-------------|-----------------|-----------------|
| Сохранить установленные программы | ✅ | ✅ |
| Сохранить переменные окружения (ENV, PATH) | ✅ | ❌ |
| Сохранить точку входа (CMD, ENTRYPOINT) | ✅ | ❌ |
| Использовать как базовый для Dockerfile | ✅ (`FROM my-image`) | ❌ |

---

### 💿 Бэкап образа в файл

#### Сохранение

```bash
# Образ → .tar файл
docker save -o backup.tar my-saved-image:v1

# Сжать (опционально)
gzip backup.tar  # получится backup.tar.gz
```

#### Восстановление

```bash
# Из .tar обратно в Docker
docker load -i backup.tar

# Если файл сжат
gunzip -c backup.tar.gz | docker load
```

---

### 🐳 Использование в Docker Compose

#### Вариант 1: Только образ (рекомендуется)

```yaml
services:
  app:
    image: my-saved-image:v1    # готовый образ из бэкапа
    container_name: my-container
    ports:
      - "8080:80"
    volumes:
      - ./data:/app/data
    restart: unless-stopped
```

**Запуск:**

```bash
docker compose up -d
```

#### Вариант 2: Сборка из Dockerfile (разработка)

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: my-container
    # ... остальные настройки
```

**Запуск:**

```bash
docker compose up -d --build
```

#### Вариант 3: Гибкий (build + образ)

```yaml
services:
  app:
    # По умолчанию - сборка
    build:
      context: .
      dockerfile: Dockerfile
    
    # С профилем prod - готовый образ
    image: my-saved-image:v1
    profiles: ["prod"]
    
    container_name: my-container
    ports:
      - "8080:80"
```

**Запуск:**

```bash
# Сборка из Dockerfile (по умолчанию)
docker compose up -d

# Готовый образ из бэкапа
docker compose --profile prod up -d
```

> **Важное замечание про профили:** Если у сервиса только `profiles` (без `build` или `image` вне профиля), то без `--profile` сервис не запустится (тихо игнорируется).

---

### 🔄 Полный цикл работы

#### Разработка и сохранение прогресса

```bash
# 1. Запустить контейнер из образа
docker compose up -d

# 2. Войти внутрь и установить новые пакеты
docker exec -it my-container bash
pip install new-package
exit

# 3. Сохранить изменения в новый образ
docker commit my-container my-image:v2

# 4. Обновить тег в docker-compose.yml (если нужно)
# image: my-image:v2
```

#### Восстановление на новом компьютере

```bash
# 1. Загрузить образ из бэкапа
docker load -i my-backup.tar

# 2. Проверить, что образ загрузился
docker images

# 3. Запустить стек
docker compose up -d
```

---

### ⚠️ Важные нюансы

#### Тома (Volumes) НЕ сохраняются в образ

```yaml
volumes:
  - ./data:/app/data     # 👈 эти данные не попадут в образ
  - database:/var/lib/postgresql
```

**Что делать:** данные из томов нужно бэкапить отдельно

```bash
# Скопировать важные файлы из контейнера
docker cp <CONTAINER_ID>:/app/data ./backup-data

# Или бэкап Docker-тома
docker run --rm -v my-volume:/source -v $(pwd):/backup alpine cp -a /source/. /backup/
```

#### Аргументы сборки (args) не работают с `image`

```yaml
build:
  args:
    USERNAME: developer   # 👈 работает при сборке
image: my-image:v1        # 👈 args игнорируются (образ уже готов)
```

---

### 📋 Полезные команды (шпаргалка)

| Команда | Назначение |
|---------|------------|
| `docker ps` | Список запущенных контейнеров |
| `docker ps -a` | Все контейнеры (включая остановленные) |
| `docker images` | Список образов |
| `docker commit <ID> <name>:<tag>` | Контейнер → образ |
| `docker save -o file.tar <image>` | Образ → .tar файл |
| `docker load -i file.tar` | .tar файл → образ |
| `docker exec -it <ID> bash` | Войти в контейнер |
| `docker logs <ID>` | Посмотреть логи |
| `docker compose up -d` | Запустить сервисы (фон) |
| `docker compose down` | Остановить и удалить контейнеры |
| `docker system prune -a` | Очистить неиспользуемые образы/контейнеры |

---

### ✅ Чек-лист: что делать при ручной настройке

- [ ] Выполнить `docker ps -a` и найти свой контейнер
- [ ] Сохранить изменения: `docker commit <ID> my-final-env:v1`
- [ ] Проверить: `docker images \| grep my-final-env`
- [ ] Сохранить в файл: `docker save -o full-backup.tar my-final-env:v1`
- [ ] Скопировать .tar на внешний диск / в облако
- [ ] В `docker-compose.yml` указать `image: my-final-env:v1`

# Создать папку workspace на хосте
mkdir -p workspace

# Установить правильного владельца (опционально)
sudo chown $UID:$GID workspace

# Запустить контейнер
docker compose up -d

# Проверить, что папка смонтирована
docker exec vscode-remote-dev ls -la /workspace