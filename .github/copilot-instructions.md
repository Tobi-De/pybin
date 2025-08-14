# pybin - Python Binary Distribution System

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

This project repackages command-line binaries from GitHub releases as Python wheels for distribution via PyPI. It allows installing CLI tools like `just`, `gh`, `scc`, etc., using `pip install toolname-bin`.

## Working Effectively

### Required Tools Installation
Install the required development tools (UV package manager and Just task runner):

```bash
# Install UV (modern Python package manager)
pip install uv

# Add to PATH if needed
export PATH=$PATH:~/.local/bin

# Install Just task runner via pybin (self-hosting)
pip install just-bin

# Verify installations
uv --version  # Should show uv version
just --version  # Should show just version
```

### Bootstrap and Setup
Initialize the development environment:

```bash
# Initialize project (creates .venv, syncs dependencies)
just init
```
**TIMING**: Takes ~5 seconds. NEVER CANCEL - Set timeout to 60+ seconds.

### Build Workflow
Build wheels for any tool in the project:

```bash
# Build wheels for a specific tool (e.g., scc, gh, just, caddy)
just build TOOL_NAME

# Examples:
just build scc     # Small binary, ~4 seconds
just build gh      # Large binary, ~10 seconds  
just build just    # Medium binary, ~6 seconds
```
**TIMING**: Small tools (scc): ~4 seconds, Large tools (gh): ~10 seconds. NEVER CANCEL - Set timeout to 300+ seconds for safety.

### Available Tools
The following tools can be built (located in `src/pybin/*/`):
- `caddy` - Web server
- `copilot` - GitHub Copilot CLI  
- `dbmate` - Database migration tool
- `dive` - Docker image explorer
- `fastfetch` - System information tool
- `gh` - GitHub CLI
- `hadolint` - Dockerfile linter
- `just` - Task runner
- `lazydocker` - Docker TUI
- `litestream` - SQLite replication
- `rclone` - Cloud sync tool
- `scc` - Code counter
- `traefik` - Reverse proxy
- `usql` - Universal SQL CLI

### Update Workflow
Update all tool versions to match upstream releases:

```bash
just update
```
**NOTE**: This command will fail in sandboxed environments due to GitHub API rate limiting (403 Forbidden). This is expected and documented.

## Validation

### Testing Built Wheels
Always validate that built wheels install and work correctly:

```bash
# After building (e.g., scc)
cd TOOL_NAME-dist/
pip install *.whl  # Install the appropriate platform wheel

# Test the installed tool
TOOL_NAME --version  # Verify version
TOOL_NAME --help     # Check help output

# Test actual functionality
scc --no-cocomo .    # Example: Run scc on current directory
gh --version         # Example: Check gh installation
just --list          # Example: List available just recipes
```

### Complete Validation Scenario
Run this complete scenario after making changes to core build logic:

1. Clean start: `rm -rf .venv *-dist/`
2. Initialize: `just init`
3. Build a small tool: `just build scc` 
4. Build a large tool: `just build gh`
5. Install and test: `pip install scc-dist/*.whl && scc --version && scc .`
6. Verify syntax: `python -m py_compile src/pybin/buildlib.py src/pybin/update.py`
7. Test new tool integration: `python -m py_compile src/pybin/*/build.py`

### Python Code Validation
Always validate Python syntax for build scripts:

```bash
# Test core modules
python -m py_compile src/pybin/buildlib.py src/pybin/update.py

# Test all build scripts  
python -m py_compile src/pybin/*/build.py
```

## Repository Structure

### Key Files
- `src/pybin/buildlib.py` - Core wheel building logic
- `src/pybin/*/build.py` - Individual tool build configurations
- `Justfile` - Task runner configuration with all build commands
- `pyproject.toml` - Python project configuration (setuptools-based)
- `uv.lock` - UV package manager lockfile
- `.github/workflows/` - CI/CD for automated building and PyPI publishing

### Build Process Flow
1. Each tool has a `build.py` defining version, upstream repo, platform mappings
2. `buildlib.py` downloads binaries from GitHub releases
3. Extracts binary and packages into wheel with proper metadata  
4. Creates platform-specific wheels for different architectures
5. Wheels placed in `TOOLNAME-dist/` directory

### Common Build Script Pattern
```python
from pybin.buildlib import build_wheels

NAME = 'toolname'
UPSTREAM_REPO = 'https://github.com/user/repo'
VERSION = '1.2.3'
PYPI_VERSION = '1.2.3'  
LICENSE = "License Name"

TARGET_TAG = {
    'platform-identifier': 'wheel-platform-tag',
    # ...
}
URL_TAG = {f"{UPSTREAM_REPO}/releases/download/v{VERSION}/{NAME}-{target}.tar.gz": tag for target, tag in TARGET_TAG.items()}

if __name__ == "__main__":
    build_wheels(NAME, PYPI_VERSION, URL_TAG, UPSTREAM_REPO, LICENSE)
```

## Common Tasks

### Adding a New Tool
1. Create `src/pybin/TOOLNAME/build.py` following the pattern above
2. Define correct platform mappings in `TARGET_TAG`  
3. Test: `just build TOOLNAME`
4. Validate: Install and test the generated wheel

### Updating Tool Versions
1. Edit the `VERSION` and `PYPI_VERSION` in `src/pybin/TOOLNAME/build.py`
2. Update `URL_TAG` if URL pattern changed
3. Test: `just build TOOLNAME`
4. Validate: Install and test functionality

### Debugging Build Issues
1. Check if upstream release exists at the expected URL
2. Verify platform identifier matches the release filename
3. Test extraction: Binary should be named exactly `TOOLNAME` in the archive
4. Check wheel platform tags match target system

## Repository Command Reference

### Available Just Commands
```bash
just --list                    # Show all available commands
just init                      # Initialize project (~5 seconds)
just build TOOL_NAME          # Build wheels for specific tool (~4-10 seconds)
just update                   # Update versions (requires GitHub API access)
just register                 # Upload to PyPI (CI only, requires credentials)
just lock [--upgrade] [PKG]   # Update dependencies
just sync [--force]           # Sync virtual environment
```

### Python Project Info
- **Language**: Python 3.10+
- **Package Manager**: UV (modern pip/virtualenv replacement)
- **Task Runner**: Just (modern make/npm scripts replacement)
- **Build System**: setuptools
- **Dependencies**: wheel, twine (for publishing)

## Known Issues

1. **GitHub API Rate Limiting**: `just update` fails in sandboxed environments with "HTTP Error 403: Forbidden". This is expected without GitHub credentials.

2. **Internet Access**: Build process downloads binaries from GitHub releases. Requires internet access to upstream repositories.

3. **Platform Dependencies**: Wheels are platform-specific. The build creates wheels for macOS (Intel/ARM) and Linux (x86_64/ARM64).

4. **Binary Naming**: Tools must have binary named exactly as `NAME` in the release archive for extraction to work.

## Example Complete Workflow

Here's a complete example workflow for a fresh developer setup:

```bash
# 1. Install required tools
pip install uv just-bin
export PATH=$PATH:~/.local/bin

# 2. Initialize project (~5 seconds)
just init

# 3. Build a tool (~4 seconds for small tools)
just build scc

# 4. Test the built wheel
pip install scc-dist/*.whl
scc --version
scc .

# 5. Validate Python code
python -m py_compile src/pybin/buildlib.py src/pybin/update.py
python -m py_compile src/pybin/*/build.py

# 6. Build another tool to test (~10 seconds for larger tools)
just build gh
ls gh-dist/  # Verify wheels were created
```

Always test your changes with the complete validation scenario above before committing.