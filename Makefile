.SUFFIXES:
.PHONY: all test deps documentation lint luals clean help

all: documentation lint test

# Help target to show available commands
help:
	@echo "Available targets:"
	@echo "  make test              - Run all tests"
	@echo "  make deps              - Install dependencies (mini.nvim)"
	@echo "  make documentation     - Generate documentation"
	@echo "  make lint              - Run linters (stylua)"
	@echo "  make luals             - Run lua-language-server checks"
	@echo "  make clean             - Remove generated files and dependencies"

# Check if deps exist, otherwise provide helpful message
check-deps:
	@if [ ! -d "deps/mini.nvim" ]; then \
		echo "Error: Dependencies not found. Run 'make deps' first."; \
		exit 1; \
	fi

# Runs all the test files
test: check-deps
	@echo "Running tests with Neovim version:"
	@nvim --version | head -n 1
	@echo ""
	@nvim --headless --noplugin -u ./scripts/minimal_init.lua \
		-c "lua require('mini.test').setup()" \
		-c "lua MiniTest.run({ execute = { reporter = MiniTest.gen_reporter.stdout({ group_depth = 2 }) } })"

# Installs mini.nvim, used for both tests and documentation
deps:
	@echo "Installing dependencies..."
	@mkdir -p deps
	@if [ -d "deps/mini.nvim" ]; then \
		echo "Updating mini.nvim..."; \
		cd deps/mini.nvim && git pull; \
	else \
		echo "Cloning mini.nvim..."; \
		git clone --depth 1 https://github.com/echasnovski/mini.nvim deps/mini.nvim; \
	fi
	@echo "Dependencies installed successfully."

# Generates the documentation
documentation: check-deps
	@echo "Generating documentation..."
	@nvim --headless --noplugin -u ./scripts/minimal_init.lua \
		-c "lua require('mini.doc').generate()" -c "qa!"
	@echo "Documentation generated successfully."

# Performs a lint check and fixes issues if possible
lint:
	@echo "Running linters..."
	@command -v stylua >/dev/null 2>&1 || { echo "Warning: 'stylua' is not installed. Skipping stylua check."; }
	@command -v stylua >/dev/null 2>&1 && stylua . -g '*.lua' -g '!deps/' -g '!nightly/' || true

# Download and run lua-language-server
luals:
	@echo "Setting up lua-language-server..."
	@mkdir -p .ci/lua-ls
	@if [ ! -f ".ci/lua-ls/bin/lua-language-server" ]; then \
		echo "Downloading lua-language-server..."; \
		if [ "$$(uname)" = "Darwin" ]; then \
			curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/3.7.4/lua-language-server-3.7.4-darwin-x64.tar.gz" | tar xzf - -C "${PWD}/.ci/lua-ls"; \
		elif [ "$$(uname)" = "Linux" ]; then \
			curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/3.7.4/lua-language-server-3.7.4-linux-x64.tar.gz" | tar xzf - -C "${PWD}/.ci/lua-ls"; \
		else \
			echo "Unsupported platform: $$(uname)"; \
			exit 1; \
		fi; \
	fi
	@$(MAKE) luals-ci

# Clean generated files and dependencies
clean:
	@echo "Cleaning up..."
	@rm -rf deps/
	@rm -rf .ci/
	@echo "Clean complete."
