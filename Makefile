.PHONY: help build up down logs shell ssh status clean

help:
	@echo "Доступные команды:"
	@echo "  make build    - Собрать Docker образ"
	@echo "  make up       - Запустить контейнер"
	@echo "  make down     - Остановить контейнер"
	@echo "  make logs     - Показать логи"
	@echo "  make shell    - Войти в контейнер через bash"
	@echo "  make ssh      - Подключиться через SSH"
	@echo "  make status   - Статус контейнера"
	@echo "  make clean    - Очистить все данные"

build:
	cp env.example .env 2>/dev/null || true
	docker-compose build

up:
	docker-compose up -d
	@echo "✅ Контейнер запущен"
	@echo "SSH порт: localhost:2222"
	@echo "Подключение: ssh developer@localhost -p 2222"

down:
	docker-compose down

logs:
	docker-compose logs -f

shell:
	docker-compose exec dev bash

ssh:
	ssh developer@localhost -p 2222

status:
	docker-compose ps

clean:
	docker-compose down -v
	docker-compose rm -fv
	docker volume prune -f
