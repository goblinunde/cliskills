SHELL := /bin/sh
PYTHON ?= python

SKILL_DIR ?= agents/skills
SKILLS = $(sort $(notdir $(wildcard $(SKILL_DIR)/*)))
SKILL_COUNT = $(words $(SKILLS))
INLINE_METADATA_SKILLS = $(sort $(patsubst $(SKILL_DIR)/%/agents/openai.yaml,%,$(wildcard $(SKILL_DIR)/*/agents/openai.yaml)))
CODEX_METADATA_SKILLS = $(INLINE_METADATA_SKILLS)
CODEX_METADATA_SKILL_COUNT = $(words $(CODEX_METADATA_SKILLS))
CLAUDE_SKILL_DIR ?= claude/skills
CLAUDE_SKILLS = $(sort $(notdir $(wildcard $(CLAUDE_SKILL_DIR)/*)))
CLAUDE_SKILL_COUNT = $(words $(CLAUDE_SKILLS))
QUICK_VALIDATE ?= scripts/quick_validate.py
DASHBOARD_SCRIPT ?= scripts/dashboard.py
SUPERPOWERS_SYNC_SCRIPT ?= scripts/sync_superpowers.sh
LIST_FORMAT ?= table

INSTALL_BASE ?= $(if $(CODEX_HOME),$(CODEX_HOME),$(HOME)/.codex)
INSTALL_DIR ?= $(INSTALL_BASE)/skills
INSTALL_MODE ?= fail
CLAUDE_INSTALL_BASE ?= $(if $(CLAUDE_HOME),$(CLAUDE_HOME),$(HOME)/.claude)
CLAUDE_INSTALL_DIR ?= $(CLAUDE_INSTALL_BASE)/skills

DIST_DIR ?= dist
DIST_BASENAME ?= cliskills-skills
DIST_FILE ?= $(DIST_DIR)/$(DIST_BASENAME).tgz
MANIFEST_FILE ?= $(DIST_DIR)/MANIFEST.txt

DOC_FILES := README.md README-zh.md AGENTS.md Makefile .gitignore
RELEASE_FILES := agents claude $(DOC_FILES)

.DEFAULT_GOAL := help

.PHONY: help info list list-ids list-metadata list-no-metadata list-claude list-claude-ids sync-claude sync-superpowers doctor validate validate-skill validate-quick validate-all install install-skill install-claude install-claude-skill dashboard deploy manifest package release clean

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make info                         - show repository paths and skill count' \
		'  make list                         - list bundled Codex skills with short descriptions' \
		'  make list-ids                     - list bundled Codex skill ids only' \
		'  make list-metadata                - list skills that include skill-local agents/openai.yaml' \
		'  make list-no-metadata             - list skills that do not include agents/openai.yaml' \
		'  make list-claude                  - list mirrored Claude skills with short descriptions' \
		'  make list-claude-ids             - list mirrored Claude skill ids only' \
		'  make dashboard                    - interactive skill dashboard for repo/Codex/Claude installs' \
		'  make sync-claude                  - refresh the project-scoped claude/skills mirror' \
		'  make sync-superpowers             - sync allowlisted superpowers SKILL.md files from upstream' \
		'  make doctor                       - verify required local tools exist' \
		'  make validate                     - validate required docs, mirrored skills, and skill-local Codex metadata' \
		'  make validate-skill SKILL=<id>    - validate one skill plus its Claude mirror and metadata' \
		'  make validate-quick               - run Codex quick_validate.py on skills with agents/openai.yaml' \
		'  make validate-all                 - run both repository and quick validation' \
		'  make install                      - install all skills safely (default INSTALL_MODE=fail)' \
		'  make install-skill SKILL=<id>     - install one skill safely (default INSTALL_MODE=fail)' \
		'  make install-claude               - install mirrored Claude skills safely (default INSTALL_MODE=fail)' \
		'  make install-claude-skill SKILL=<id> - install one mirrored Claude skill safely (default INSTALL_MODE=fail)' \
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
	@printf 'Install mode: %s\n' "$(INSTALL_MODE)"
	@printf 'Dist file: %s\n' "$(DIST_FILE)"
	@printf 'Quick validator: %s\n' "$(QUICK_VALIDATE)"
	@printf 'Codex skills discovered (%s): %s\n' "$(SKILL_COUNT)" "$(SKILLS)"
	@printf 'Skills with Codex metadata (%s): %s\n' "$(CODEX_METADATA_SKILL_COUNT)" "$(CODEX_METADATA_SKILLS)"
	@printf 'Claude skills discovered (%s): %s\n' "$(CLAUDE_SKILL_COUNT)" "$(CLAUDE_SKILLS)"

list:
	@test -f "$(DASHBOARD_SCRIPT)" || { echo "Missing dashboard script: $(DASHBOARD_SCRIPT)"; exit 1; }
	@MAKE_BIN="$(MAKE)" \
	REPO_ROOT="$(CURDIR)" \
	SKILL_DIR="$(SKILL_DIR)" \
	CLAUDE_SKILL_DIR="$(CLAUDE_SKILL_DIR)" \
	INSTALL_DIR="$(INSTALL_DIR)" \
	CLAUDE_INSTALL_DIR="$(CLAUDE_INSTALL_DIR)" \
	INSTALL_MODE="$(INSTALL_MODE)" \
	LIST_FORMAT="$(LIST_FORMAT)" \
	ACTION="list-repo" \
	"$(PYTHON)" "$(DASHBOARD_SCRIPT)"

list-ids:
	@$(MAKE) list LIST_FORMAT=ids

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
	@test -f "$(DASHBOARD_SCRIPT)" || { echo "Missing dashboard script: $(DASHBOARD_SCRIPT)"; exit 1; }
	@MAKE_BIN="$(MAKE)" \
	REPO_ROOT="$(CURDIR)" \
	SKILL_DIR="$(SKILL_DIR)" \
	CLAUDE_SKILL_DIR="$(CLAUDE_SKILL_DIR)" \
	INSTALL_DIR="$(INSTALL_DIR)" \
	CLAUDE_INSTALL_DIR="$(CLAUDE_INSTALL_DIR)" \
	INSTALL_MODE="$(INSTALL_MODE)" \
	LIST_FORMAT="$(LIST_FORMAT)" \
	ACTION="list-claude-mirror" \
	"$(PYTHON)" "$(DASHBOARD_SCRIPT)"

list-claude-ids:
	@$(MAKE) list-claude LIST_FORMAT=ids

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

sync-superpowers:
	@test -f "$(SUPERPOWERS_SYNC_SCRIPT)" || { echo "Missing superpowers sync script: $(SUPERPOWERS_SYNC_SCRIPT)"; exit 1; }
	@REPO_ROOT="$(CURDIR)" "$(SUPERPOWERS_SYNC_SCRIPT)"

install-claude: validate
	@mkdir -p "$(CLAUDE_INSTALL_DIR)"
	@case "$(INSTALL_MODE)" in fail|overwrite|keep) ;; *) echo "Unknown INSTALL_MODE: $(INSTALL_MODE)"; exit 1;; esac
	@for skill in $(CLAUDE_SKILLS); do \
		src="$(CLAUDE_SKILL_DIR)/$$skill"; \
		dst="$(CLAUDE_INSTALL_DIR)/$$skill"; \
		src_manifest=$$(mktemp); \
		dst_manifest=$$(mktemp); \
		extras_manifest=$$(mktemp); \
		if [ ! -e "$$dst" ]; then \
			cp -R "$$src" "$(CLAUDE_INSTALL_DIR)/"; \
			echo "Installed $$skill -> $$dst"; \
		else \
			(cd "$$src" && find . -type f | sort > "$$src_manifest"); \
			missing_or_changed=0; \
			while IFS= read -r rel; do \
				if [ ! -f "$$dst/$$rel" ] || ! cmp -s "$$src/$$rel" "$$dst/$$rel"; then \
					missing_or_changed=1; \
					break; \
				fi; \
			done < "$$src_manifest"; \
			if [ "$$missing_or_changed" -eq 0 ]; then \
				(cd "$$dst" && find . -type f | sort > "$$dst_manifest"); \
				grep -Fxv -f "$$src_manifest" "$$dst_manifest" > "$$extras_manifest" || true; \
				if [ -s "$$extras_manifest" ]; then \
					echo "Unchanged $$skill -> $$dst (local extra files preserved)"; \
				else \
					echo "Unchanged $$skill -> $$dst"; \
				fi; \
			else \
				case "$(INSTALL_MODE)" in \
					fail) echo "Conflict for $$dst; re-run with INSTALL_MODE=overwrite or INSTALL_MODE=keep"; rm -f "$$src_manifest" "$$dst_manifest" "$$extras_manifest"; exit 1 ;; \
					overwrite) rm -rf "$$dst"; cp -R "$$src" "$(CLAUDE_INSTALL_DIR)/"; echo "Overwritten $$skill -> $$dst" ;; \
					keep) echo "Kept existing $$skill -> $$dst" ;; \
				esac; \
			fi; \
		fi; \
		rm -f "$$src_manifest" "$$dst_manifest" "$$extras_manifest"; \
	done

doctor:
	@for tool in $(PYTHON) cmp cp diff grep tar find sort mktemp; do \
		command -v "$$tool" >/dev/null 2>&1 || { echo "Missing required tool: $$tool"; exit 1; }; \
	done
	@$(PYTHON) -c 'import yaml' >/dev/null 2>&1 || { echo "Missing Python package: pyyaml"; exit 1; }
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
		src_manifest=$$(mktemp); \
		claude_manifest=$$(mktemp); \
		(cd "$$dir" && find . -path './agents' -prune -o -type f -print | sort > "$$src_manifest"); \
		(cd "$$claude_dir" && find . -type f -print | sort > "$$claude_manifest"); \
		cmp -s "$$src_manifest" "$$claude_manifest" || { \
			echo "Claude mirror file list differs for $$skill"; \
			diff -u "$$src_manifest" "$$claude_manifest" || true; \
			rm -f "$$src_manifest" "$$claude_manifest"; \
			exit 1; \
		}; \
		while IFS= read -r rel; do \
			cmp -s "$$dir/$$rel" "$$claude_dir/$$rel" || { \
				echo "Claude mirror file content differs for $$skill: $$rel"; \
				rm -f "$$src_manifest" "$$claude_manifest"; \
				exit 1; \
			}; \
		done < "$$src_manifest"; \
		rm -f "$$src_manifest" "$$claude_manifest"; \
		done; \
	echo "Validated $$count skill(s), mirrored Claude skills, repository docs, and skill-local Codex metadata."

validate-skill:
	@test -n "$(SKILL)" || { echo "Usage: make validate-skill SKILL=<skill-id>"; exit 1; }
	@test -d "$(SKILL_DIR)/$(SKILL)" || { echo "Unknown skill: $(SKILL)"; exit 1; }
	@test -d "$(CLAUDE_SKILL_DIR)" || { echo "Missing $(CLAUDE_SKILL_DIR)"; exit 1; }
	@for doc in $(DOC_FILES); do \
		[ -f "$$doc" ] || { echo "Missing required file: $$doc"; exit 1; }; \
	done
	@dir="$(SKILL_DIR)/$(SKILL)"; \
	claude_dir="$(CLAUDE_SKILL_DIR)/$(SKILL)"; \
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
	src_manifest=$$(mktemp); \
	claude_manifest=$$(mktemp); \
	(cd "$$dir" && find . -path './agents' -prune -o -type f -print | sort > "$$src_manifest"); \
	(cd "$$claude_dir" && find . -type f -print | sort > "$$claude_manifest"); \
	cmp -s "$$src_manifest" "$$claude_manifest" || { \
		echo "Claude mirror file list differs for $(SKILL)"; \
		diff -u "$$src_manifest" "$$claude_manifest" || true; \
		rm -f "$$src_manifest" "$$claude_manifest"; \
		exit 1; \
	}; \
	while IFS= read -r rel; do \
		cmp -s "$$dir/$$rel" "$$claude_dir/$$rel" || { \
			echo "Claude mirror file content differs for $(SKILL): $$rel"; \
			rm -f "$$src_manifest" "$$claude_manifest"; \
			exit 1; \
		}; \
	done < "$$src_manifest"; \
	rm -f "$$src_manifest" "$$claude_manifest"; \
	echo "Validated skill $(SKILL), its Claude mirror, repository docs, and skill-local Codex metadata."

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
	@case "$(INSTALL_MODE)" in fail|overwrite|keep) ;; *) echo "Unknown INSTALL_MODE: $(INSTALL_MODE)"; exit 1;; esac
	@for skill in $(SKILLS); do \
		src="$(SKILL_DIR)/$$skill"; \
		dst="$(INSTALL_DIR)/$$skill"; \
		src_manifest=$$(mktemp); \
		dst_manifest=$$(mktemp); \
		extras_manifest=$$(mktemp); \
		if [ ! -e "$$dst" ]; then \
			cp -R "$$src" "$(INSTALL_DIR)/"; \
			echo "Installed $$skill -> $$dst"; \
		else \
			(cd "$$src" && find . -type f | sort > "$$src_manifest"); \
			missing_or_changed=0; \
			while IFS= read -r rel; do \
				if [ ! -f "$$dst/$$rel" ] || ! cmp -s "$$src/$$rel" "$$dst/$$rel"; then \
					missing_or_changed=1; \
					break; \
				fi; \
			done < "$$src_manifest"; \
			if [ "$$missing_or_changed" -eq 0 ]; then \
				(cd "$$dst" && find . -type f | sort > "$$dst_manifest"); \
				grep -Fxv -f "$$src_manifest" "$$dst_manifest" > "$$extras_manifest" || true; \
				if [ -s "$$extras_manifest" ]; then \
					echo "Unchanged $$skill -> $$dst (local extra files preserved)"; \
				else \
					echo "Unchanged $$skill -> $$dst"; \
				fi; \
			else \
				case "$(INSTALL_MODE)" in \
					fail) echo "Conflict for $$dst; re-run with INSTALL_MODE=overwrite or INSTALL_MODE=keep"; rm -f "$$src_manifest" "$$dst_manifest" "$$extras_manifest"; exit 1 ;; \
					overwrite) rm -rf "$$dst"; cp -R "$$src" "$(INSTALL_DIR)/"; echo "Overwritten $$skill -> $$dst" ;; \
					keep) echo "Kept existing $$skill -> $$dst" ;; \
				esac; \
			fi; \
		fi; \
		rm -f "$$src_manifest" "$$dst_manifest" "$$extras_manifest"; \
	done

install-skill: validate-skill
	@test -n "$(SKILL)" || { echo "Usage: make install-skill SKILL=<skill-id>"; exit 1; }
	@test -d "$(SKILL_DIR)/$(SKILL)" || { echo "Unknown skill: $(SKILL)"; exit 1; }
	@mkdir -p "$(INSTALL_DIR)"
	@case "$(INSTALL_MODE)" in fail|overwrite|keep) ;; *) echo "Unknown INSTALL_MODE: $(INSTALL_MODE)"; exit 1;; esac
	@src="$(SKILL_DIR)/$(SKILL)"; \
	dst="$(INSTALL_DIR)/$(SKILL)"; \
	src_manifest=$$(mktemp); \
	dst_manifest=$$(mktemp); \
	extras_manifest=$$(mktemp); \
	if [ ! -e "$$dst" ]; then \
		cp -R "$$src" "$(INSTALL_DIR)/"; \
		echo "Installed $(SKILL) -> $$dst"; \
	else \
		(cd "$$src" && find . -type f | sort > "$$src_manifest"); \
		missing_or_changed=0; \
		while IFS= read -r rel; do \
			if [ ! -f "$$dst/$$rel" ] || ! cmp -s "$$src/$$rel" "$$dst/$$rel"; then \
				missing_or_changed=1; \
				break; \
			fi; \
		done < "$$src_manifest"; \
		if [ "$$missing_or_changed" -eq 0 ]; then \
			(cd "$$dst" && find . -type f | sort > "$$dst_manifest"); \
			grep -Fxv -f "$$src_manifest" "$$dst_manifest" > "$$extras_manifest" || true; \
			if [ -s "$$extras_manifest" ]; then \
				echo "Unchanged $(SKILL) -> $$dst (local extra files preserved)"; \
			else \
				echo "Unchanged $(SKILL) -> $$dst"; \
			fi; \
		else \
			case "$(INSTALL_MODE)" in \
				fail) echo "Conflict for $$dst; re-run with INSTALL_MODE=overwrite or INSTALL_MODE=keep"; rm -f "$$src_manifest" "$$dst_manifest" "$$extras_manifest"; exit 1 ;; \
				overwrite) rm -rf "$$dst"; cp -R "$$src" "$(INSTALL_DIR)/"; echo "Overwritten $(SKILL) -> $$dst" ;; \
				keep) echo "Kept existing $(SKILL) -> $$dst" ;; \
			esac; \
		fi; \
	fi; \
	rm -f "$$src_manifest" "$$dst_manifest" "$$extras_manifest"

install-claude-skill: validate-skill
	@test -n "$(SKILL)" || { echo "Usage: make install-claude-skill SKILL=<skill-id>"; exit 1; }
	@test -d "$(CLAUDE_SKILL_DIR)/$(SKILL)" || { echo "Unknown Claude mirror skill: $(SKILL)"; exit 1; }
	@mkdir -p "$(CLAUDE_INSTALL_DIR)"
	@case "$(INSTALL_MODE)" in fail|overwrite|keep) ;; *) echo "Unknown INSTALL_MODE: $(INSTALL_MODE)"; exit 1;; esac
	@src="$(CLAUDE_SKILL_DIR)/$(SKILL)"; \
	dst="$(CLAUDE_INSTALL_DIR)/$(SKILL)"; \
	src_manifest=$$(mktemp); \
	dst_manifest=$$(mktemp); \
	extras_manifest=$$(mktemp); \
	if [ ! -e "$$dst" ]; then \
		cp -R "$$src" "$(CLAUDE_INSTALL_DIR)/"; \
		echo "Installed $(SKILL) -> $$dst"; \
	else \
		(cd "$$src" && find . -type f | sort > "$$src_manifest"); \
		missing_or_changed=0; \
		while IFS= read -r rel; do \
			if [ ! -f "$$dst/$$rel" ] || ! cmp -s "$$src/$$rel" "$$dst/$$rel"; then \
				missing_or_changed=1; \
				break; \
			fi; \
		done < "$$src_manifest"; \
		if [ "$$missing_or_changed" -eq 0 ]; then \
			(cd "$$dst" && find . -type f | sort > "$$dst_manifest"); \
			grep -Fxv -f "$$src_manifest" "$$dst_manifest" > "$$extras_manifest" || true; \
			if [ -s "$$extras_manifest" ]; then \
				echo "Unchanged $(SKILL) -> $$dst (local extra files preserved)"; \
			else \
				echo "Unchanged $(SKILL) -> $$dst"; \
			fi; \
		else \
			case "$(INSTALL_MODE)" in \
				fail) echo "Conflict for $$dst; re-run with INSTALL_MODE=overwrite or INSTALL_MODE=keep"; rm -f "$$src_manifest" "$$dst_manifest" "$$extras_manifest"; exit 1 ;; \
				overwrite) rm -rf "$$dst"; cp -R "$$src" "$(CLAUDE_INSTALL_DIR)/"; echo "Overwritten $(SKILL) -> $$dst" ;; \
				keep) echo "Kept existing $(SKILL) -> $$dst" ;; \
			esac; \
		fi; \
	fi; \
	rm -f "$$src_manifest" "$$dst_manifest" "$$extras_manifest"

dashboard:
	@test -f "$(DASHBOARD_SCRIPT)" || { echo "Missing dashboard script: $(DASHBOARD_SCRIPT)"; exit 1; }
	@MAKE_BIN="$(MAKE)" \
	REPO_ROOT="$(CURDIR)" \
	SKILL_DIR="$(SKILL_DIR)" \
	CLAUDE_SKILL_DIR="$(CLAUDE_SKILL_DIR)" \
	INSTALL_DIR="$(INSTALL_DIR)" \
	CLAUDE_INSTALL_DIR="$(CLAUDE_INSTALL_DIR)" \
	INSTALL_MODE="$(INSTALL_MODE)" \
	LIST_FORMAT="$(LIST_FORMAT)" \
	ACTION="$(ACTION)" \
	SKILL="$(SKILL)" \
	"$(PYTHON)" "$(DASHBOARD_SCRIPT)"

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
