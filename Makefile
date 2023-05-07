SHELL=bash

.PHONY: *

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

HOST_OS := $(shell uname -s)
ifeq ($(HOST_OS),Darwin)
    THREADS := $(shell sysctl -n hw.logicalcpu)
endif
ifeq ($(HOST_OS),Linux)
    THREADS := $(shell nproc)
endif

# Fallback to only 1 thread if `HOST_OS` is unknown
ifndef THREADS
    THREADS := 1
endif

PROJECT_NAME="app-metrics-talk"
LOCAL_COMPOSER_HOME=$(shell composer config --global home 2> /dev/null || echo ${HOME}/.config/composer)
LOCAL_COMPOSER_CACHE_DIR=$(shell composer config --global cache-dir 2> /dev/null || echo ${HOME}/.config/composer/cache)

DOCKER_RUN=@docker run --rm -it \
    -v "${current_dir}:/opt" \
    -v "${LOCAL_COMPOSER_HOME}:/.config/composer" \
    -v "${LOCAL_COMPOSER_CACHE_DIR}:/tmp/composer/cache" \
    -e COMPOSER_HOME=/.config/composer \
    -e COMPOSER_CACHE_DIR=/tmp/composer/cache \
    -e COMPOSER_MEMORY_LIMIT=-1 \
    -e HISTFILE="/opt/project/var/shell/.bash_history" \
    -e PROMPT_COMMAND="history -a" \
    -e XDEBUG_MODE=coverage \
    "${PROJECT_NAME}:dev-latest"

export DOCKER_BUILDKIT=1

all: install style-fix style-check test static-analysis coverage-check ## Runs everything

install: docker-build composer-install

test: test-unit test-integration test-mutation ## Runs all test suite

docker-build:
	docker build -t "${PROJECT_NAME}:dev-latest" --target=dev -f docker/php/Dockerfile .
	docker build -t "${PROJECT_NAME}:runtime" --target=runtime -f docker/php/Dockerfile .

docker-check:
ifeq ($(shell docker images --filter=reference="${PROJECT_NAME}:dev-latest" --format={{.ID}}),)
	$(MAKE) docker-build
endif

composer-install: docker-check ## Install dependencies with composer
	$(DOCKER_RUN) composer install -n -o

shell: docker-check ## Gives shell access inside the container
	$(DOCKER_RUN) sh

serve: docker-check
	@docker-compose up -d

help:
	@echo "\033[33mUsage:\033[0m\n  make [target] [FLAGS=\"val\"...]\n\n\033[33mTargets:\033[0m"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}'
