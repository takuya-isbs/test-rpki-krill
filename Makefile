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

DATA_DIRS = data-root data-host1 data-host2

init-dir:
	mkdir -p $(DATA_DIRS)

init-conf:
	./gen-conf.sh

# Use SoftHSM : https://krill.docs.nlnetlabs.nl/en/stable/hsm.html
SO_PIN = 1234
PIN = 5678
COMPOSE_RUN_HOST1 = $(COMPOSE) run --rm -it krill-host1
PKCS11_TOOL = pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --login --pin $(PIN)
LABEL = My RPKI host1

init-hsm:
	$(COMPOSE_RUN_HOST1) softhsm2-util --init-token --free --label "$(LABEL)" --so-pin $(SO_PIN) --pin $(PIN)

hsm-list-objects:
	$(COMPOSE_RUN_HOST1) $(PKCS11_TOOL) --list-objects

init: init-dir init-conf init-hsm hsm-list-objects

up: init-dir
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

down-volume:
	$(COMPOSE) down -v

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

test-all:
	./test-updown.sh
	./test-roa.sh
	./test-api-roa.sh

define _clean-TESTDIR
	rm -rf ./TESTDIR
endef

clean-TESTDIR:
	./confirm.sh
	$(call _clean-TESTDIR)

define _DELETE-ALL-DATA
	rm -rI $(DATA_DIRS) || :
endef

CLEAN-ALL:
	./confirm.sh
	#make down || :
	$(COMPOSE) down
	$(call _clean-TESTDIR)
	$(call _DELETE-ALL-DATA)
	@echo "DONE: CLEAN-ALL"
