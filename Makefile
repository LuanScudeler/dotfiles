DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
HOMEBREW_PREFIX ?= $(shell brew --prefix 2>/dev/null || echo /home/linuxbrew/.linuxbrew)
export PATH := $(HOMEBREW_PREFIX)/bin:$(DOTFILES_DIR)/bin:$(PATH)
SHELL := /bin/bash
export XDG_CONFIG_HOME = $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)
export ACCEPT_EULA=Y

.PHONY: prereqs test

all: ubuntu

# Privileged prerequisites (need sudo). Run these yourself: `make prereqs`
prereqs:
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get install -y build-essential procps curl file git

ubuntu: brew packages-ubuntu node-packages link

brew:
	is-executable brew || NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

packages-ubuntu: brew
	brew bundle --verbose --file=$(DOTFILES_DIR)/install/Brewfile || true

stow-ubuntu: brew
	is-executable stow || brew install stow

# Node LTS is managed by mise; the global default lives in ~/.config/mise/config.toml.
# npm globals are installed through the mise-selected Node.
node-packages: packages-ubuntu
	mise use -g node@lts
	mise exec -- npm install --force --location global --allow-scripts=pnpm,yarn,puppeteer,esbuild $(shell cat install/npmfile)

link: stow-ubuntu
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
		mv -v $(HOME)/$$FILE{,.bak}; fi; done
	mkdir -p "$(XDG_CONFIG_HOME)"
	stow -t "$(HOME)" runcom
	stow -t "$(XDG_CONFIG_HOME)" --ignore='^agents$$' config
	stow --no-folding -d "$(DOTFILES_DIR)/config" -t "$(HOME)" agents

unlink: stow-ubuntu
	stow --delete -t "$(HOME)" runcom
	stow --delete -t "$(XDG_CONFIG_HOME)" --ignore='^agents$$' config
	stow --delete -d "$(DOTFILES_DIR)/config" -t "$(HOME)" agents
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then \
		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

test:
	bats test
