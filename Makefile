NAME        = inception

-include srcs/.env

USER_LOG := $(shell echo $${SUDO_USER:-$$(whoami)})

COMPOSE		:= USER_LOG=$(USER_LOG) docker compose -f srcs/docker-compose.yml
DATA_PATH	= /home/$(USER_LOG)/data

CERT_HOST_FILE := $(shell realpath -m srcs/$(NGINX_SSL_CERTIFICATE_HOST_FILE))
CERT_KEY_FILE  := $(shell realpath -m srcs/$(NGINX_SSL_CERTIFICATE_KEY_HOST_FILE))
CERT_DIR       := $(dir $(CERT_HOST_FILE))

VOLUMES    	:= mariadb wordpress

all: prepare
	$(COMPOSE) up -d --build

prepare:
	@for vol in $(VOLUMES); do \
		mkdir -p $(DATA_PATH)/$$vol; \
	done
		
	@mkdir -p "$(CERT_DIR)"
	echo "$(PWD)"
	echo "$(CERT_DIR)"
	
	@if [ ! -f "$(CERT_DIR)/inception_nginx.crt" ]; then \
		echo "Generating SSL certificate"; \
		openssl req -x509 -nodes \
			-days 365 \
			-newkey rsa:2048 \
			-keyout "$(CERT_KEY_FILE)" \
			-out "$(CERT_HOST_FILE)" \
			-subj "/CN=$(DOMAIN_NAME)"; \
	fi
# -subj "/C=DE/ST=Baden-Wurttemberg/L=Heilbronn/O=42/CN=localhost"

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
	@$(COMPOSE) ps -a

	@echo "\n==================== DATA ======================"
	@du -sh $(DATA_PATH) 2>/dev/null || echo "No data directory"


.PHONY: all up down stop start logs clean fclean f re info
