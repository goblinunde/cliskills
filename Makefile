SHELL := /bin/sh

SKILL_DIR ?= .agents/skills
INSTALL_BASE ?= $(if $(CODEX_HOME),$(CODEX_HOME),$(HOME)/.codex)
INSTALL_DIR ?= $(INSTALL_BASE)/skills
DIST_DIR ?= dist
DIST_FILE ?= $(DIST_DIR)/cliskills-skills.tgz

.PHONY: help list validate install deploy package clean

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make list      - list bundled skills' \
		'  make validate  - validate required skill files' \
		'  make install   - copy skills into $${CODEX_HOME:-$$HOME/.codex}/skills' \
		'  make deploy    - alias for make install' \
		'  make package   - create a release archive in dist/' \
		'  make clean     - remove generated archives'

list:
	@test -d "$(SKILL_DIR)" || { echo "Missing $(SKILL_DIR)"; exit 1; }
	@found=0; \
	for skill in $(SKILL_DIR)/*; do \
		[ -d "$$skill" ] || continue; \
		found=1; \
		printf '%s\n' "$$(basename "$$skill")"; \
	done; \
	[ "$$found" -eq 1 ] || { echo "No skills found under $(SKILL_DIR)"; exit 1; }

validate:
	@test -d "$(SKILL_DIR)" || { echo "Missing $(SKILL_DIR)"; exit 1; }
	@count=0; \
	for skill in $(SKILL_DIR)/*; do \
		[ -d "$$skill" ] || continue; \
		count=$$((count + 1)); \
		[ -f "$$skill/SKILL.md" ] || { echo "Missing $$skill/SKILL.md"; exit 1; }; \
		grep -q '^---$$' "$$skill/SKILL.md" || { echo "Missing frontmatter in $$skill/SKILL.md"; exit 1; }; \
		grep -q '^name:[[:space:]]' "$$skill/SKILL.md" || { echo "Missing name: in $$skill/SKILL.md"; exit 1; }; \
		grep -q '^description:[[:space:]]' "$$skill/SKILL.md" || { echo "Missing description: in $$skill/SKILL.md"; exit 1; }; \
		[ -f "$$skill/agents/openai.yaml" ] || { echo "Missing $$skill/agents/openai.yaml"; exit 1; }; \
	done; \
	[ "$$count" -gt 0 ] || { echo "No skills found under $(SKILL_DIR)"; exit 1; }; \
	echo "Validated $$count skill(s)."

install: validate
	@mkdir -p "$(INSTALL_DIR)"
	@for skill in $(SKILL_DIR)/*; do \
		[ -d "$$skill" ] || continue; \
		name=$$(basename "$$skill"); \
		rm -rf "$(INSTALL_DIR)/$$name"; \
		cp -R "$$skill" "$(INSTALL_DIR)/"; \
		echo "Installed $$name -> $(INSTALL_DIR)/$$name"; \
	done

deploy: install

package: validate
	@mkdir -p "$(DIST_DIR)"
	@tar -czf "$(DIST_FILE)" .agents README.md AGENTS.md Makefile
	@echo "Created $(DIST_FILE)"

clean:
	@rm -rf "$(DIST_DIR)"
	@echo "Removed $(DIST_DIR)"
