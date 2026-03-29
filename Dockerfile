# TrimUI Brick Cross-Compilation Docker Image
# ARM64 cross-compilation environment for Debian-based builds

FROM --platform=linux/amd64 debian:bullseye-slim

# Install ARM64 cross-compiler and SDL2 libraries
RUN dpkg --add-architecture arm64 && \
	apt-get update && \
	apt-get install -y \
	g++-aarch64-linux-gnu \
	libsdl2-dev:arm64 \
	libsdl2-ttf-dev:arm64 \
	&& rm -rf /var/lib/apt/lists/*

# Configure pkg-config for cross-compilation
ENV PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
ENV PKG_CONFIG_ALLOW_CROSS=1

WORKDIR /project
