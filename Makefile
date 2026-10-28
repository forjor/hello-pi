# hello-pi — drive the pre-configured, read-only Pi agent against whichever
# provider key you export.
#
# Quick start (inside the devcontainer):
#   export ANTHROPIC_API_KEY=...   # Claude   (or GEMINI_API_KEY / XAI_API_KEY)
#   make hello
#
# `make hello` runs pi non-interactively (--print), trusts this repo's
# pre-configured agent in .pi/ (--approve), restricts it to read-only tools,
# and sends the prompt "identify yourself and say hello". The provider and a
# default model are selected from whichever key is exported (first match wins:
# Claude, then Gemini, then Grok).
#
# Overrides:
#   make hello MODEL=claude-sonnet-4-5            # pin a model within the detected provider
#   make hello MODEL=openai/gpt-5 PROVIDER=       # different provider (clear PROVIDER, needs its key)
#   make hello PROMPT="who are you?"

SHELL := /bin/bash

PROMPT ?= identify yourself and say hello

# Read-only tool allowlist (no write/edit/bash). See pi docs: `pi --tools read,grep,find,ls`.
READONLY_TOOLS ?= read,grep,find,ls

# Default model pattern per provider (fuzzy; pi resolves it against the live catalog).
ANTHROPIC_MODEL ?= sonnet
GEMINI_MODEL    ?= gemini
XAI_MODEL       ?= grok

# Derive PROVIDER + MODEL from the exported key unless MODEL was supplied.
# (Environment variables are visible to make; ifdef is false when empty.)
ifndef MODEL
ifdef ANTHROPIC_API_KEY
PROVIDER ?= anthropic
MODEL := $(ANTHROPIC_MODEL)
else ifdef GEMINI_API_KEY
PROVIDER ?= google
MODEL := $(GEMINI_MODEL)
else ifdef XAI_API_KEY
PROVIDER ?= xai
MODEL := $(XAI_MODEL)
endif
endif

# Pass --provider only when PROVIDER is set (omit it to use a MODEL of the form provider/id).
PI_PROVIDER_ARG := $(if $(strip $(PROVIDER)),--provider $(PROVIDER),)

.PHONY: hello help
.DEFAULT_GOAL := help

hello:
	@command -v pi >/dev/null 2>&1 || { echo "pi not found. Rebuild the devcontainer (it installs @earendil-works/pi-coding-agent)."; exit 1; }
ifndef MODEL
	@echo "No provider key found. Export exactly one of:"; \
	echo "  export ANTHROPIC_API_KEY=...   # Claude"; \
	echo "  export GEMINI_API_KEY=...      # Gemini"; \
	echo "  export XAI_API_KEY=...         # Grok"; \
	exit 1
endif
	@echo "→ pi --print (read-only: $(READONLY_TOOLS)) · provider: $(if $(strip $(PROVIDER)),$(PROVIDER),auto) · model: $(MODEL)"
	@pi --print --approve --no-session $(PI_PROVIDER_ARG) --model "$(MODEL)" --tools $(READONLY_TOOLS) "$(PROMPT)"

help:
	@echo "Targets:"
	@echo "  make hello   Run the pre-configured read-only Pi agent: 'identify yourself and say hello'"
	@echo ""
	@echo "Export a provider key first: ANTHROPIC_API_KEY, GEMINI_API_KEY, or XAI_API_KEY"
	@echo "Override: make hello MODEL=provider/model PROVIDER= PROMPT=\"...\""
