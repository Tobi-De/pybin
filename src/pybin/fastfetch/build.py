from pybin.buildlib import build_wheels

NAME = 'fastfetch'
UPSTREAM_REPO = "https://github.com/fastfetch-cli/fastfetch"
VERSION = '2.50.1'
PYPI_VERSION = '2.50.1'
LICENSE = "MIT"

# Adapted for newer naming scheme used in versions 2.46.0+
# Note: macos-arm64 is NOT available - only macos-amd64 (Intel Mac) is provided
# The macos-amd64 binary should work on Apple Silicon Macs via Rosetta 2
TARGET_TAG = {
    'macos-amd64': 'macosx_10_9_x86_64',     # Intel macOS (also works on Apple Silicon via Rosetta)
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
