DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := srcs/.env
DATA_DIR := /home/${USER}/data
WORDPRESS_DATA := $(DATA_DIR)/wordpress
MARIADB_DATA := $(DATA_DIR)/mariadb
DOMAIN = ${USER}.42.fr
DC = cd srcs && docker compose

name = inception

all: setup build up

setup:
	sudo mkdir -p $(WORDPRESS_DATA)
	sudo mkdir -p $(MARIADB_DATA)
	sudo chmod 777 $(WORDPRESS_DATA)
	sudo chmod 777 $(MARIADB_DATA)
	if ! grep -q $(DOMAIN) /etc/hosts; then echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts; fi

build:
	$(DC) build --no-cache

up:
	$(DC) up -d

down:
	$(DC) down

clean: down
	docker system prune -af
	if [ "$$(docker volume ls -q)" ]; then docker volume rm $$(docker volume ls -q); fi

fclean: clean
	sudo rm -rf $(DATA_DIR)
	sudo sed -i '/$(DOMAIN)/d' /etc/hosts
status:
	@echo "container status"
	@$(DC) ps
	@echo "\ndocker images status"
	@docker images
	@echo "\ndocker volumes status"
	@docker volume ls
	@echo "\nnetwork status"
	@docker network ls

logs:
	@$(DC) logs -f

restart: down up

re: fclean all

.PHONY: all setup build up down re clean fclean logs
