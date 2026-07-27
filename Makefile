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

fclean: clean
	@docker run --rm -v $(DATA_PATH):/data \
	alpine \
	sh -c 'rm -rf $(addprefix /data/,$(VOLUMES))'

re: fclean all

.PHONY: all up down stop start logs clean fclean re
