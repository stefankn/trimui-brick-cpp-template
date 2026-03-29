# TrimUI Brick C++ Project Template
# Adjust PROJECT_NAME and customize as needed

# Load PROJECT_NAME from .env if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Project configuration
PROJECT_NAME ?= my-brick-app
TARGET = $(PROJECT_NAME)

# Directories
SRC_DIR = src
INC_DIR = include
LIB_DIR = lib

# Source files (automatically includes all .cpp files in src/)
SRCS = $(wildcard $(SRC_DIR)/*.cpp)

# C++17 standard with all warnings enabled
CXXFLAGS = -std=c++17 -Wall -I$(INC_DIR) -I$(LIB_DIR)

# -- macOS build flags --
# Uses locally installed SDL2 via Homebrew
HOST_CFLAGS = $(shell sdl2-config --cflags) $(shell pkg-config --cflags SDL2_ttf)
HOST_LIBS   = $(shell sdl2-config --libs)   $(shell pkg-config --libs SDL2_ttf)

# -- ARM64 cross-compilation flags --
CROSS_CC = aarch64-linux-gnu-g++

# Default target: build for host (macOS)
.PHONY: all
all: host

# Host build (macOS development)
.PHONY: host
host: $(SRCS)
	g++ $(CXXFLAGS) -g $(HOST_CFLAGS) -o $(TARGET) $(SRCS) $(HOST_LIBS)

# Cross-compile for TrimUI Brick (ARM64 Linux)
.PHONY: brick
brick:
	docker run --rm --platform=linux/amd64 \
		-v $(PWD):/project \
		-w /project \
		brick-cross-cpp:latest \
		$(CROSS_CC) $(CXXFLAGS) \
		-Iinclude -Ilib -I/usr/include/SDL2 \
		-o $(TARGET)-brick \
		$(SRCS) \
		-lSDL2 -lSDL2_ttf -lpthread

# Build Docker image for cross-compilation
.PHONY: docker-build
docker-build:
	docker build -t brick-cross-cpp:latest .

# Clean build artifacts
.PHONY: clean
clean:
	rm -f $(TARGET) $(TARGET)-brick

# Generate compile_commands.json for LSP (clangd)
.PHONY: compile-commands
compile-commands:
	bear -- make host

.PHONY: help
help:
	@echo "TrimUI Brick C++ Project Template"
	@echo ""
	@echo "Targets:"
	@echo "  make host              - Build for macOS (development)"
	@echo "  make brick             - Cross-compile for TrimUI Brick (ARM64)"
	@echo "  make docker-build      - Build Docker cross-compilation image"
	@echo "  make clean             - Remove build artifacts"
	@echo "  make compile-commands  - Generate compile_commands.json for LSP"
	@echo ""
	@echo "Deployment:"
	@echo "  ./scripts/deploy.sh    - Build and deploy to Brick via FTP"
