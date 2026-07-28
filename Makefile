NAME          = inception

USER_LOG := $(shell echo $${SUDO_USER:-$$(whoami)})

COMPOSE       := USER_LOG=$(USER_LOG) docker compose -f srcs/docker-compose.yml
DATA_PATH     = /home/$(USER_LOG)/data
VOLUMES       := mariadb wordpress

all: prepare
	$(COMPOSE) up -d --build

prepare:
	@for vol in $(VOLUMES); do \
		mkdir -p $(DATA_PATH)/$$vol; \
	done

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down --rmi all --volumes

fclean f: clean
# 	@docker run --rm -v $(DATA_PATH):/data \
# 	alpine \
# 	sh -c 'rm -rf $(addprefix /data/,$(VOLUMES))'
	@docker run --rm -v $(DATA_PATH):/data alpine sh -c 'rm -rf /data/*'

re: fclean all

info:
	@echo "================== CONTAINERS =================="
	@docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"

	@echo "\n==================== IMAGES ===================="
	@docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"

	@echo "\n==================== VOLUMES ==================="
	@docker volume ls

	@echo "\n==================== NETWORKS =================="
	@docker network ls

	@echo "\n==================== DISK USAGE ================"
	@docker system df

	@echo "\n==================== PROJECT ==================="
	@$(COMPOSE) ps

	@echo "\n==================== DATA ======================"
	@du -sh $(DATA_PATH) 2>/dev/null || echo "No data directory"


.PHONY: all up down stop start logs clean fclean f re info
