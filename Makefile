COMPOSE = docker compose
HOSTS = krill-root krill-host1 krill-host2

define gen_target
       $(foreach name,$(HOSTS),$(1)@$(name))
endef

.PONY =

TARGET_SHELL = $(call gen_target,shell)
.PONY += $(TARGET_SHELL)

TARGET_SHELLROOT = $(call gen_target,shell-root)
.PONY += $(TARGET_SHELLROOT)

TARGET_LOGS = $(call gen_target,logs)
.PONY += $(TARGET_LOGS)

TARGET_LOGS_F = $(call gen_target,logs-follow)
.PONY += $(TARGET_LOGS_F)

ps:
	$(COMPOSE) ps

init:
	mkdir -p data-root data-host1 data-host2

up: init
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

build:
	$(COMPOSE) build

build-nocache:
	$(COMPOSE) build --no-cache

$(TARGET_SHELL): shell@%:
	$(COMPOSE) exec $* /bin/bash

$(TARGET_SHELLROOT): shell-root@%:
	$(COMPOSE) exec -u root $* /bin/bash

$(TARGET_LOGS): logs@%:
	$(COMPOSE) logs $*

$(TARGET_LOGS_F): logs-follow@%:
	$(COMPOSE) logs --follow $*

test-updown:
	./test-updown.sh

test-roa:
	./test-roa.sh

test-api-roa:
	./test-api-roa.sh

clean-TESTDIR:
	rm -rf ./TESTDIR
