.PHONY: test up down

COMPOSE := docker compose -f test/docker-compose.yaml

test:
	lua test/unit_ja4h.lua

up:
	$(COMPOSE) up --build --watch

down:
	$(COMPOSE) down
