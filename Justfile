@default:
    just --list

@init:
    [ -f uv.lock ] && echo "Lockfile already exists" || just lock
    just sync

lock UPGRADE="noupgrade" PACKAGE="":
    #!/usr/bin/env bash
    if [ "{{UPGRADE}}" = "--upgrade" ] && [ -n "{{PACKAGE}}" ]; then
        uv lock --upgrade-package "{{PACKAGE}}"
    elif [ "{{UPGRADE}}" = "--upgrade" ] || [ "{{UPGRADE}}" = "-U" ]; then
        uv lock --upgrade
    else
        uv lock
    fi

sync FORCE="noforce":
    #!/usr/bin/env bash
    if [ "{{FORCE}}" = "--force" ]  || [ "{{FORCE}}" = "-f" ]; then
        rm -rf {{justfile_directory()}}/.venv
    fi
    uv sync --frozen

@build APP_NAME: init
    uv run --no-sync python -m pybin.{{APP_NAME}}.build

@register:
    git diff --name-only HEAD^1 HEAD -G"^PYPI_VERSION =" "*build.py" | uniq | xargs -n1 dirname | xargs -n1 basename | xargs -I {} sh -c 'just _register {}'

@_register APP_NAME: init (build APP_NAME)
    uv run --no-sync twine upload -u $PYPI_USERNAME -p $PYPI_PASSWORD {{APP_NAME}}-dist/*

# Build changed packages and collect wheels in dist/ directory for trusted publishing
@build_for_trusted_publishing: init
    #!/usr/bin/env bash
    set -euo pipefail  # Exit on error, undefined vars, pipe failures
    
    # Create dist directory
    rm -rf dist/
    mkdir -p dist/
    
    # Find packages with version changes and build them
    changed_files=$(git diff --name-only HEAD^1 HEAD -G"^PYPI_VERSION =" "*build.py" || true)
    
    if [ -z "$changed_files" ]; then
        echo "No packages found with PYPI_VERSION changes"
        echo "Creating empty dist/ directory"
        ls -la dist/
        exit 0
    fi
    
    echo "Found changed build files:"
    echo "$changed_files"
    echo ""
    
    packages=$(echo "$changed_files" | xargs -n1 dirname | xargs -n1 basename | sort -u)
    
    # Build each package and copy wheels to dist/
    for package in $packages; do
        echo "Building package: $package"
        just build $package
        
        if [ -d "${package}-dist" ]; then
            cp ${package}-dist/* dist/ 2>/dev/null || true
            echo "Copied wheels from ${package}-dist/ to dist/"
        else
            echo "Warning: ${package}-dist directory not found"
        fi
    done
    
    echo ""
    echo "Built packages: $packages"
    echo "Final dist/ contents:"
    ls -la dist/

@update: init
    uv run --no-sync python -m pybin.update
