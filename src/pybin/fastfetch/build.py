from pybin.buildlib import build_wheels

NAME = 'fastfetch'
UPSTREAM_REPO = "https://github.com/fastfetch-cli/fastfetch"
VERSION = '2.38.0'
PYPI_VERSION = '2.38.0'
LICENSE = "MIT"

# Using version 2.38.0 because newer versions have extraction issues
# Newer versions (2.50.1+) have changed archive structure or file ordering 
# that causes buildlib.py to extract bash completion instead of the binary
# Fixed the duplicate 'macos-universal' key issue from original config
TARGET_TAG = {
    'macos-universal': 'macosx_10_9_x86_64',  # Intel macOS 
    'linux-aarch64': 'manylinux_2_17_aarch64.manylinux2014_aarch64.musllinux_1_1_aarch64',
    'linux-amd64': 'manylinux_2_12_x86_64.manylinux2010_x86_64.musllinux_1_1_x86_64',
}
URL_TAG = {f"{UPSTREAM_REPO}/releases/download/{VERSION}/{NAME}-{target}.tar.gz": tag for target, tag in TARGET_TAG.items()}


if __name__ == "__main__":
    build_wheels(
        NAME,
        PYPI_VERSION,
        URL_TAG,
        UPSTREAM_REPO,
        LICENSE,
        )
