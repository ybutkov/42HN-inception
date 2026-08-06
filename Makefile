NAME        = inception

-include srcs/.env

USER_LOG := $(shell echo $${SUDO_USER:-$$(whoami)})

COMPOSE		:= USER_LOG=$(USER_LOG) docker compose -f srcs/docker-compose.yml
DATA_PATH	= /home/$(USER_LOG)/data

CERT_HOST_FILE := $(shell realpath -m srcs/$(NGINX_SSL_CERTIFICATE_HOST_FILE))
CERT_KEY_FILE  := $(shell realpath -m srcs/$(NGINX_SSL_CERTIFICATE_KEY_HOST_FILE))
CERT_DIR       := $(dir $(CERT_HOST_FILE))

SECRETS = db_root_password.txt \
          db_admin_password.txt \
          db_wp_user_password.txt \
          wp_admin_password.txt \
          wp_user_password.txt \
          ftp_password.txt \
          portainer_admin_password.txt

SECRETS_DIR = secrets

VOLUMES    	:= mariadb wordpress redis portainer

all: prepare up
	

prepare:	
	@for vol in $(VOLUMES); do \
		mkdir -p "$(DATA_PATH)/$$vol"; \
		chmod 777 "$(DATA_PATH)/$$vol" 2>/dev/null || true; \
	done

	@mkdir -p "$(CERT_DIR)"

	@mkdir -p "$(SECRETS_DIR)"
	@for secret_file in $(SECRETS); do \
		if [ ! -f "$(SECRETS_DIR)/$$secret_file" ]; then \
			echo "Creating empty secret file(has to be filled): $(SECRETS_DIR)/$$secret_file"; \
			touch "$(SECRETS_DIR)/$$secret_file"; \
			chmod 600 "$(SECRETS_DIR)/$$secret_file"; \
		fi; \
	done
	
	@if [ ! -f "$(CERT_DIR)/inception_nginx.crt" ]; then \
		echo "Generating SSL certificate"; \
		openssl req -x509 -nodes \
			-days 365 \
			-newkey rsa:2048 \
			-keyout "$(CERT_KEY_FILE)" \
			-out "$(CERT_HOST_FILE)" \
			-subj "/C=DE/ST=Baden-Wurttemberg/L=Heilbronn/O=42/CN=$(DOMAIN_NAME)" \
			-addext "subjectAltName=DNS:$(DOMAIN_NAME),DNS:me.$(DOMAIN_NAME)"; \
	fi

up:
	$(COMPOSE) up -d --build
	
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

# Sync local env/secrets with the remote VM
cpenv:
	SSH_PORT=14242; \
	HOST_APP_DIR=/home/ybutkov/Documents/Curriculum/inception; \
	VM_APP_DIR=/home/ybutkov/Documents/42HN-inception; \
	scp -P $$SSH_PORT $$HOST_APP_DIR/srcs/.env ybutkov@127.0.0.1:$$VM_APP_DIR/srcs/ ; \
	scp -P $$SSH_PORT -r $$HOST_APP_DIR/secrets ybutkov@127.0.0.1:$$VM_APP_DIR


.PHONY: all up down stop start logs clean fclean f re info cpenv
