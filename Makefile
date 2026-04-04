SHELL := /bin/sh
PYTHON ?= python

SKILL_DIR ?= agents/skills
SKILLS := $(sort $(notdir $(wildcard $(SKILL_DIR)/*)))
SKILL_COUNT := $(words $(SKILLS))
INLINE_METADATA_SKILLS := $(sort $(patsubst $(SKILL_DIR)/%/agents/openai.yaml,%,$(wildcard $(SKILL_DIR)/*/agents/openai.yaml)))
CODEX_METADATA_SKILLS := $(INLINE_METADATA_SKILLS)
CODEX_METADATA_SKILL_COUNT := $(words $(CODEX_METADATA_SKILLS))
CLAUDE_SKILL_DIR ?= claude/skills
CLAUDE_SKILLS := $(sort $(notdir $(wildcard $(CLAUDE_SKILL_DIR)/*)))
CLAUDE_SKILL_COUNT := $(words $(CLAUDE_SKILLS))
QUICK_VALIDATE ?= /home/yyt/.codex/skills/.system/skill-creator/scripts/quick_validate.py

INSTALL_BASE ?= $(if $(CODEX_HOME),$(CODEX_HOME),$(HOME)/.codex)
INSTALL_DIR ?= $(INSTALL_BASE)/skills
CLAUDE_INSTALL_BASE ?= $(if $(CLAUDE_HOME),$(CLAUDE_HOME),$(HOME)/.claude)
CLAUDE_INSTALL_DIR ?= $(CLAUDE_INSTALL_BASE)/skills

DIST_DIR ?= dist
DIST_BASENAME ?= cliskills-skills
DIST_FILE ?= $(DIST_DIR)/$(DIST_BASENAME).tgz
MANIFEST_FILE ?= $(DIST_DIR)/MANIFEST.txt

DOC_FILES := README.md README-zh.md AGENTS.md Makefile .gitignore
RELEASE_FILES := agents claude $(DOC_FILES)

.DEFAULT_GOAL := help

.PHONY: help info list list-metadata list-no-metadata list-claude sync-claude doctor validate validate-quick validate-all install install-skill install-claude deploy manifest package release clean

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make info                         - show repository paths and skill count' \
		'  make list                         - list bundled skill ids from the Codex source tree' \
		'  make list-metadata                - list skills that include skill-local agents/openai.yaml' \
		'  make list-no-metadata             - list skills that do not include agents/openai.yaml' \
		'  make list-claude                  - list mirrored Claude skill ids' \
		'  make sync-claude                  - refresh the project-scoped claude/skills mirror' \
		'  make doctor                       - verify required local tools exist' \
		'  make validate                     - validate required docs, mirrored skills, and skill-local Codex metadata' \
		'  make validate-quick               - run Codex quick_validate.py on skills with agents/openai.yaml' \
		'  make validate-all                 - run both repository and quick validation' \
		'  make install                      - copy all skills to $${CODEX_HOME:-$$HOME/.codex}/skills' \
		'  make install-skill SKILL=<id>     - install one skill by id' \
		'  make install-claude               - copy mirrored skills to $${CLAUDE_HOME:-$$HOME/.claude}/skills' \
		'  make deploy                       - alias for make install' \
		'  make manifest                     - write a release manifest to dist/' \
		'  make package                      - create a release archive in dist/' \
		'  make release                      - run sync-claude, doctor, validate-all, manifest, and package' \
		'  make clean                        - remove generated dist artifacts'

info:
	@printf 'Repository root: %s\n' "$$(pwd)"
	@printf 'Codex skill dir: %s\n' "$(SKILL_DIR)"
	@printf 'Claude project skill dir: %s\n' "$(CLAUDE_SKILL_DIR)"
	@printf 'Claude install dir: %s\n' "$(CLAUDE_INSTALL_DIR)"
	@printf 'Install dir: %s\n' "$(INSTALL_DIR)"
	@printf 'Dist file: %s\n' "$(DIST_FILE)"
	@printf 'Quick validator: %s\n' "$(QUICK_VALIDATE)"
	@printf 'Codex skills discovered (%s): %s\n' "$(SKILL_COUNT)" "$(SKILLS)"
	@printf 'Skills with Codex metadata (%s): %s\n' "$(CODEX_METADATA_SKILL_COUNT)" "$(CODEX_METADATA_SKILLS)"
	@printf 'Claude skills discovered (%s): %s\n' "$(CLAUDE_SKILL_COUNT)" "$(CLAUDE_SKILLS)"

list:
	@test -d "$(SKILL_DIR)" || { echo "Missing $(SKILL_DIR)"; exit 1; }
	@test -n "$(SKILLS)" || { echo "No skills found under $(SKILL_DIR)"; exit 1; }
	@for skill in $(SKILLS); do \
		printf '%s\n' "$$skill"; \
	done

list-metadata:
	@if [ -z "$(CODEX_METADATA_SKILLS)" ]; then \
		echo "No skills with agents/openai.yaml found."; \
		exit 0; \
	fi
	@for skill in $(CODEX_METADATA_SKILLS); do \
		printf '%s\n' "$$skill"; \
	done

list-no-metadata:
	@for skill in $(SKILLS); do \
		case " $(CODEX_METADATA_SKILLS) " in \
			*" $$skill "*) ;; \
			*) printf '%s\n' "$$skill";; \
		esac; \
	done

list-claude:
	@test -d "$(CLAUDE_SKILL_DIR)" || { echo "Missing $(CLAUDE_SKILL_DIR)"; exit 1; }
	@test -n "$(CLAUDE_SKILLS)" || { echo "No skills found under $(CLAUDE_SKILL_DIR)"; exit 1; }
	@for skill in $(CLAUDE_SKILLS); do \
		printf '%s\n' "$$skill"; \
	done

sync-claude:
	@test -d "$(SKILL_DIR)" || { echo "Missing $(SKILL_DIR)"; exit 1; }
	@test -n "$(SKILLS)" || { echo "No skills found under $(SKILL_DIR)"; exit 1; }
	@mkdir -p "$(CLAUDE_SKILL_DIR)"
	@for skill in $(CLAUDE_SKILLS); do \
		case " $(SKILLS) " in \
			*" $$skill "*) ;; \
			*) rm -rf "$(CLAUDE_SKILL_DIR)/$$skill"; echo "Removed stale $$skill";; \
		esac; \
	done
	@for skill in $(SKILLS); do \
		src="$(SKILL_DIR)/$$skill"; \
		dst="$(CLAUDE_SKILL_DIR)/$$skill"; \
		rm -rf "$$dst"; \
		mkdir -p "$$dst"; \
		find "$$src" -mindepth 1 -maxdepth 1 ! -name agents -exec cp -R {} "$$dst"/ \; ; \
		echo "Synced $$skill -> $$dst"; \
	done

install-claude: validate
	@mkdir -p "$(CLAUDE_INSTALL_DIR)"
	@for skill in $(CLAUDE_SKILLS); do \
		rm -rf "$(CLAUDE_INSTALL_DIR)/$$skill"; \
		cp -R "$(CLAUDE_SKILL_DIR)/$$skill" "$(CLAUDE_INSTALL_DIR)/"; \
		echo "Installed $$skill -> $(CLAUDE_INSTALL_DIR)/$$skill"; \
	done

doctor:
	@for tool in $(PYTHON) cp grep tar find sort mktemp; do \
		command -v "$$tool" >/dev/null 2>&1 || { echo "Missing required tool: $$tool"; exit 1; }; \
	done
	@if [ -f "$(QUICK_VALIDATE)" ]; then \
		echo "Codex quick validator found."; \
	else \
		echo "Codex quick validator not found at $(QUICK_VALIDATE)."; \
	fi
	@echo "Local tool check passed."

validate:
	@test -d "$(SKILL_DIR)" || { echo "Missing $(SKILL_DIR)"; exit 1; }
	@test -n "$(SKILLS)" || { echo "No skills found under $(SKILL_DIR)"; exit 1; }
	@test -d "$(CLAUDE_SKILL_DIR)" || { echo "Missing $(CLAUDE_SKILL_DIR)"; exit 1; }
	@if [ "$(SKILLS)" != "$(CLAUDE_SKILLS)" ]; then \
		echo "Codex and Claude skill sets differ."; \
		echo "Codex : $(SKILLS)"; \
		echo "Claude: $(CLAUDE_SKILLS)"; \
		echo "Run: make sync-claude"; \
		exit 1; \
	fi
	@for doc in $(DOC_FILES); do \
		[ -f "$$doc" ] || { echo "Missing required file: $$doc"; exit 1; }; \
	done
	@count=0; \
	for skill in $(SKILLS); do \
		dir="$(SKILL_DIR)/$$skill"; \
		claude_dir="$(CLAUDE_SKILL_DIR)/$$skill"; \
		count=$$((count + 1)); \
		[ -f "$$dir/SKILL.md" ] || { echo "Missing $$dir/SKILL.md"; exit 1; }; \
		[ -f "$$claude_dir/SKILL.md" ] || { echo "Missing $$claude_dir/SKILL.md"; exit 1; }; \
		grep -q '^---$$' "$$dir/SKILL.md" || { echo "Missing frontmatter in $$dir/SKILL.md"; exit 1; }; \
		grep -q '^name:[[:space:]]' "$$dir/SKILL.md" || { echo "Missing name: in $$dir/SKILL.md"; exit 1; }; \
		grep -q '^description:[[:space:]]' "$$dir/SKILL.md" || { echo "Missing description: in $$dir/SKILL.md"; exit 1; }; \
		grep -q '^---$$' "$$claude_dir/SKILL.md" || { echo "Missing frontmatter in $$claude_dir/SKILL.md"; exit 1; }; \
		grep -q '^description:[[:space:]]' "$$claude_dir/SKILL.md" || { echo "Missing description: in $$claude_dir/SKILL.md"; exit 1; }; \
		meta_file="$$dir/agents/openai.yaml"; \
		[ -f "$$meta_file" ] || { echo "Missing $$meta_file"; exit 1; }; \
		grep -q 'display_name:' "$$meta_file" || { echo "Missing display_name in $$meta_file"; exit 1; }; \
		grep -q 'short_description:' "$$meta_file" || { echo "Missing short_description in $$meta_file"; exit 1; }; \
		grep -q 'default_prompt:' "$$meta_file" || { echo "Missing default_prompt in $$meta_file"; exit 1; }; \
		done; \
	echo "Validated $$count skill(s), mirrored Claude skills, repository docs, and skill-local Codex metadata."

validate-quick:
	@test -f "$(QUICK_VALIDATE)" || { echo "Missing quick validator: $(QUICK_VALIDATE)"; exit 1; }
	@if [ -z "$(CODEX_METADATA_SKILLS)" ]; then \
		echo "No skills with agents/openai.yaml found; skipping quick validation."; \
		exit 0; \
	fi
	@for skill in $(CODEX_METADATA_SKILLS); do \
		$(PYTHON) "$(QUICK_VALIDATE)" "$(SKILL_DIR)/$$skill" || exit 1; \
	done
	@echo "Codex quick_validate passed for $(CODEX_METADATA_SKILL_COUNT) metadata-backed skill(s)."

validate-all: validate validate-quick
	@echo "All validation layers passed."

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
		echo "Codex skills: $(SKILLS)"; \
		echo "Claude skills: $(CLAUDE_SKILLS)"; \
		echo "Codex metadata-backed skills: $(CODEX_METADATA_SKILLS)"; \
		echo ""; \
		find agents -type f | sort; \
		echo ""; \
		find claude -type f | sort; \
		echo ""; \
		for doc in $(DOC_FILES); do echo "$$doc"; done; \
	} > "$(MANIFEST_FILE)"
	@echo "Wrote $(MANIFEST_FILE)"

package: manifest
	@tar -czf "$(DIST_FILE)" $(RELEASE_FILES) "$(MANIFEST_FILE)"
	@echo "Created $(DIST_FILE)"

release: sync-claude doctor validate-all manifest package
	@echo "Release artifacts are ready under $(DIST_DIR)"

clean:
	@rm -rf "$(DIST_DIR)"
	@echo "Removed $(DIST_DIR)"
