# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a C++ template for building applications on the **TrimUI Brick** handheld device (ARM64 Linux, 1024x768 screen). The workflow is: develop and test on macOS, cross-compile for ARM64 via Docker, deploy to device over SSH/FTP.

## Build Commands

Copy `.env.example` to `.env` and configure before building/deploying.

```sh
make host            # Compile for macOS (requires SDL2 via Homebrew)
make brick           # Cross-compile for ARM64 TrimUI Brick (requires Docker)
make docker-build    # Build the cross-compilation Docker image (run once)
make clean           # Remove build artifacts
make compile-commands # Generate compile_commands.json for LSP (requires Bear)
```

Deploy to device (requires `.env` with `BRICK_IP`, `BRICK_PASS`, `FTP_USER`):
```sh
./scripts/deploy.sh
```

## Architecture

### Cross-Compilation Setup
- `Dockerfile` defines an ARM64 Debian environment with `aarch64-linux-gnu-g++`, SDL2, and SDL2_ttf for ARM64
- `Makefile` uses `make host` for macOS (Homebrew SDL2) and `make brick` to invoke Docker cross-compilation
- Conditional compile flag `__linux__` controls fullscreen mode on device vs. windowed on macOS

### Source Structure
- `src/main.cpp` — single entry point; SDL2 init, event loop, render loop at 60 FPS
- `include/` — add your header files here
- `lib/` — add third-party libraries here
- `assets/` — add fonts, images, etc.; these are copied into the PAK during deployment

### Deployment (PAK format)
`scripts/deploy.sh` builds the ARM64 binary, packages it into a PAK folder (`deploy/${PAK_NAME}/`), generates a `launch.sh` entry point (sets SDL driver env vars), and uploads to `/mnt/SDCARD/Tools/tg5040/${PAK_NAME}/` on the device via SCP/FTP.

### Input Mapping (TrimUI Brick)
Joystick buttons (SDL_JOYBUTTONDOWN): B=0, A=1, Y=2, X=3. D-pad via `SDL_JOYHATMOTION`. Keyboard arrow keys and Escape also supported for macOS development.

## Environment Configuration

All deployment settings are in `.env` (gitignored):
- `PROJECT_NAME` — binary name
- `PAK_NAME` — defaults to `${PROJECT_NAME}.pak`
- `BRICK_IP` — device IP (default: `192.168.0.142`)
- `BRICK_PASS` — SSH password (default: `tina`)
- `FTP_USER` — FTP credentials (default: `minui:minui`)
