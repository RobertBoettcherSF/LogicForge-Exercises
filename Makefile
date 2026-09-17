# LogicForge-Exercises — delegate to per-exercise folders.
# Default exercise for top-level make test / make play.

EXERCISE ?= sequence_match

.PHONY: all test play clean list help

help:
	@echo "Usage:"
	@echo "  make test                 # run $(EXERCISE) tests"
	@echo "  make play                 # interactive $(EXERCISE) CLI"
	@echo "  make test EXERCISE=path_plan"
	@echo "  make list                 # list exercise folders"
	@echo "Or: cd sequence_match && make test"

list:
	@ls -d */ 2>/dev/null | sed 's|/||' | grep -v '^obj$$' || true

all test play clean:
	@if [ ! -d "$(EXERCISE)" ]; then \
	  echo "No folder: $(EXERCISE)"; \
	  echo "Try: make list"; \
	  exit 1; \
	fi
	$(MAKE) -C $(EXERCISE) $@

