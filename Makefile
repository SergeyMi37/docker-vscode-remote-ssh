.PHONY: help build up down logs shell ssh status clean setup-keys show-key

HOST_IP := $(shell ip -4 route get 1 | awk '{for(i=1;i<=NF;i++) if($$i=="src") print $$(i+1)}')

help:
	@echo "Доступные команды:"
	@echo "  make build       - Собрать Docker образ"
	@echo "  make up          - Запустить контейнер"
	@echo "  make down        - Остановить контейнер"
	@echo "  make setup-keys  - Создать SSH ключи на хосте"
	@echo "  make show-key    - Показать публичный ключ для Forgejo"
	@echo "  make ssh         - Подключиться через SSH"
	@echo "  make logs        - Показать логи"
	@echo "  make shell       - Войти в контейнер"
	@echo "  make status      - Статус контейнера"
	@echo "  make clean       - Очистить все данные"

build:
	@if [ ! -f .env ]; then \
		cp .env.example .env 2>/dev/null || echo "DEV_USER=developer" > .env; \
	fi
	docker compose build

up:
	@if [ ! -d ./ssh-keys ] || [ -z "$$(ls -A ./ssh-keys 2>/dev/null)" ]; then \
		echo "⚠️  SSH ключи не найдены. Запустите: make setup-keys"; \
	fi
	docker compose up -d
	@echo ""
	@echo "✅ Контейнер запущен"
	@echo "========================================="
	@echo "SSH доступ: $(HOST_IP):2222"
	@echo "Подключение: ssh developer@$(HOST_IP) -p 2222"
	@echo "========================================="

down:
	docker compose down

setup-keys:
	@./man-ssh-setup.sh create
	@./man-ssh-setup.sh show

show-key:
	@./man-ssh-setup.sh show

sync-keys:
	@./man-ssh-setup.sh sync

ssh:
	@ssh -p 2222 developer@$(HOST_IP)

logs:
	docker compose logs -f

shell:
	docker compose exec dev bash

status:
	docker compose ps

clean:
	docker compose down -v
	rm -rf ./ssh-keys
	docker compose rm -fv
	docker volume prune -f
	@echo "✅ Очистка завершена"