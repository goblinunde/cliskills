SHELL := /bin/sh

SKILL_DIR ?= .agents/skills
SKILLS := $(sort $(notdir $(wildcard $(SKILL_DIR)/*)))
SKILL_COUNT := $(words $(SKILLS))

INSTALL_BASE ?= $(if $(CODEX_HOME),$(CODEX_HOME),$(HOME)/.codex)
INSTALL_DIR ?= $(INSTALL_BASE)/skills

DIST_DIR ?= dist
DIST_BASENAME ?= cliskills-skills
DIST_FILE ?= $(DIST_DIR)/$(DIST_BASENAME).tgz
MANIFEST_FILE ?= $(DIST_DIR)/MANIFEST.txt

DOC_FILES := README.md README-zh.md AGENTS.md Makefile .gitignore
RELEASE_FILES := .agents $(DOC_FILES)

.DEFAULT_GOAL := help

.PHONY: help info list doctor validate install install-skill deploy manifest package release clean

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make info                         - show repository paths and skill count' \
		'  make list                         - list bundled skill ids' \
		'  make doctor                       - verify required local tools exist' \
		'  make validate                     - validate skill metadata and required docs' \
		'  make install                      - copy all skills to $${CODEX_HOME:-$$HOME/.codex}/skills' \
		'  make install-skill SKILL=<id>     - install one skill by id' \
		'  make deploy                       - alias for make install' \
		'  make manifest                     - write a release manifest to dist/' \
		'  make package                      - create a release archive in dist/' \
		'  make release                      - run doctor, validate, manifest, and package' \
		'  make clean                        - remove generated dist artifacts'

info:
	@printf 'Repository root: %s\n' "$$(pwd)"
	@printf 'Skill source dir: %s\n' "$(SKILL_DIR)"
	@printf 'Install dir: %s\n' "$(INSTALL_DIR)"
	@printf 'Dist file: %s\n' "$(DIST_FILE)"
	@printf 'Skills discovered (%s): %s\n' "$(SKILL_COUNT)" "$(SKILLS)"

list:
	@test -d "$(SKILL_DIR)" || { echo "Missing $(SKILL_DIR)"; exit 1; }
	@test -n "$(SKILLS)" || { echo "No skills found under $(SKILL_DIR)"; exit 1; }
	@for skill in $(SKILLS); do \
		printf '%s\n' "$$skill"; \
	done

doctor:
	@for tool in cp grep tar find sort; do \
		command -v "$$tool" >/dev/null 2>&1 || { echo "Missing required tool: $$tool"; exit 1; }; \
	done
	@echo "Local tool check passed."

validate:
	@test -d "$(SKILL_DIR)" || { echo "Missing $(SKILL_DIR)"; exit 1; }
	@test -n "$(SKILLS)" || { echo "No skills found under $(SKILL_DIR)"; exit 1; }
	@for doc in $(DOC_FILES); do \
		[ -f "$$doc" ] || { echo "Missing required file: $$doc"; exit 1; }; \
	done
	@count=0; \
	for skill in $(SKILLS); do \
		dir="$(SKILL_DIR)/$$skill"; \
		count=$$((count + 1)); \
		[ -f "$$dir/SKILL.md" ] || { echo "Missing $$dir/SKILL.md"; exit 1; }; \
		[ -f "$$dir/agents/openai.yaml" ] || { echo "Missing $$dir/agents/openai.yaml"; exit 1; }; \
		grep -q '^---$$' "$$dir/SKILL.md" || { echo "Missing frontmatter in $$dir/SKILL.md"; exit 1; }; \
		grep -q '^name:[[:space:]]' "$$dir/SKILL.md" || { echo "Missing name: in $$dir/SKILL.md"; exit 1; }; \
		grep -q '^description:[[:space:]]' "$$dir/SKILL.md" || { echo "Missing description: in $$dir/SKILL.md"; exit 1; }; \
		grep -q 'display_name:' "$$dir/agents/openai.yaml" || { echo "Missing display_name in $$dir/agents/openai.yaml"; exit 1; }; \
		grep -q 'short_description:' "$$dir/agents/openai.yaml" || { echo "Missing short_description in $$dir/agents/openai.yaml"; exit 1; }; \
		grep -q 'default_prompt:' "$$dir/agents/openai.yaml" || { echo "Missing default_prompt in $$dir/agents/openai.yaml"; exit 1; }; \
	done; \
	echo "Validated $$count skill(s) and repository docs."

install: validate
	@mkdir -p "$(INSTALL_DIR)"
	@for skill in $(SKILLS); do \
		rm -rf "$(INSTALL_DIR)/$$skill"; \
		cp -R "$(SKILL_DIR)/$$skill" "$(INSTALL_DIR)/"; \
		echo "Installed $$skill -> $(INSTALL_DIR)/$$skill"; \
	done

install-skill: validate
	@test -n "$(SKILL)" || { echo "Usage: make install-skill SKILL=<skill-id>"; exit 1; }
	@test -d "$(SKILL_DIR)/$(SKILL)" || { echo "Unknown skill: $(SKILL)"; exit 1; }
	@mkdir -p "$(INSTALL_DIR)"
	@rm -rf "$(INSTALL_DIR)/$(SKILL)"
	@cp -R "$(SKILL_DIR)/$(SKILL)" "$(INSTALL_DIR)/"
	@echo "Installed $(SKILL) -> $(INSTALL_DIR)/$(SKILL)"

deploy: install

manifest: validate
	@mkdir -p "$(DIST_DIR)"
	@{ \
		echo "cliskills release manifest"; \
		echo "Archive: $(DIST_FILE)"; \
		echo "Skills: $(SKILLS)"; \
		echo ""; \
		find .agents -type f | sort; \
		echo ""; \
		for doc in $(DOC_FILES); do echo "$$doc"; done; \
	} > "$(MANIFEST_FILE)"
	@echo "Wrote $(MANIFEST_FILE)"

package: manifest
	@tar -czf "$(DIST_FILE)" $(RELEASE_FILES) "$(MANIFEST_FILE)"
	@echo "Created $(DIST_FILE)"

release: doctor manifest package
	@echo "Release artifacts are ready under $(DIST_DIR)"

clean:
	@rm -rf "$(DIST_DIR)"
	@echo "Removed $(DIST_DIR)"
