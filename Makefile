# Standalone TVB-O lecture deck
# Point SRC at the workshop repo (default assumes it sits next to this one).
SRC ?= ../tvb-ontology-optim-workshop

.DEFAULT_GOAL := help

.PHONY: help sync render preview all clean

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-9s\033[0m %s\n",$$1,$$2}'

sync:  ## Pull slides + materials from the workshop repo (override: make sync SRC=/path)
	SRC="$(SRC)" ./sync.sh

render:  ## Render the deck -> index.html (uses the _freeze cache, no Python needed)
	quarto render

preview:  ## Live-reloading preview
	quarto preview

all: sync render  ## Sync from the workshop repo, then render

clean:  ## Remove render artifacts
	rm -rf .quarto index.html index_files mathjax-config.js _site
