NAME        = inception

-include srcs/.env

USER_LOG 		:= $(shell echo $${SUDO_USER:-$$(whoami)})
DATA_PATH 		= /home/$(USER_LOG)/data

COMPOSE			:= DATA_PATH=$(DATA_PATH) docker compose -f srcs/docker-compose.yml

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

SERVICE_COMMANDS := up start stop restart logs

ENTRYPOINT_LIB := srcs/scripts/entrypoint-lib.sh
TARGET_DIRS    := srcs/requirements/nginx/tools/ \
                  srcs/requirements/wordpress/tools/ \
                  srcs/requirements/mariadb/tools/ \
                  srcs/requirements/bonus/ftp_server/tools/ \
                  srcs/requirements/bonus/portainer/tools/

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
		echo "Generating SSL certificate..."; \
		openssl req -x509 -nodes \
			-days 365 \
			-newkey rsa:2048 \
			-keyout "$(CERT_KEY_FILE)" \
			-out "$(CERT_HOST_FILE)" \
			-subj "/C=DE/ST=Baden-Wurttemberg/L=Heilbronn/O=42/CN=$(DOMAIN_NAME)" \
			-addext "subjectAltName=DNS:$(DOMAIN_NAME),DNS:me.$(DOMAIN_NAME)"; \
	fi

.copy-lib:
	@echo "Copying entrypoint library to services..."
	@for dir in $(TARGET_DIRS); do cp $(ENTRYPOINT_LIB) $$dir; done

.clean-lib:
	@echo "Cleaning up entrypoint library copies..."
	@for dir in $(TARGET_DIRS); do rm -f $$dir/entrypoint-lib.sh; done

ifneq ($(filter $(firstword $(MAKECMDGOALS)),$(SERVICE_COMMANDS)),)
  SERVICE_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(SERVICE_ARGS):;@:)
endif

up: .copy-lib
	$(COMPOSE) up -d --build $(SERVICE_ARGS)
	
start:
	$(COMPOSE) start $(SERVICE_ARGS)

stop:
	$(COMPOSE) stop $(SERVICE_ARGS)

restart:
	$(COMPOSE) restart $(SERVICE_ARGS)

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f $(SERVICE_ARGS)

clean: .clean-lib
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
