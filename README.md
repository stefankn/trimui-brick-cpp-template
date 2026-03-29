# TrimUI Brick C++ Template

A template project for developing C++ applications for the TrimUI Brick handheld gaming device.

## Features

- Cross-compilation setup using Docker
- Local development support on macOS/Linux
- SDL2 integration with joystick and TTF support
- Automated deployment to device via SSH/SCP
- Ready-to-use project structure

## Prerequisites

### For Development (macOS)
```bash
brew install sdl2 sdl2_ttf pkg-config
```

### For Cross-compilation
- Docker installed and running

### For LSP Support (Optional)
```bash
brew install bear  # Generates compile_commands.json for clangd
```

## Quick Start

1. Clone or copy this template
2. Customize `PROJECT_NAME` in `Makefile`
3. Update IP address in `scripts/deploy.sh` if needed
4. Build and deploy:

```bash
make brick      # Build for Brick
./scripts/deploy.sh    # Deploy to device
```

## Build Commands

### Development Build (macOS/Linux)
```bash
make host           # Compile for local development
./my-brick-app      # Run locally
```

### Production Build (Brick)
```bash
make brick          # Cross-compile using Docker
```

This creates an ARM64 binary that runs on the TrimUI Brick.

### Deploy to Brick
```bash
./scripts/deploy.sh
```

This script will:
1. Build the ARM64 binary
2. Create PAK folder structure
3. Copy binary, launch script, and assets
4. Deploy to Brick via SSH/SCP

### Clean Build Artifacts
```bash
make clean
```

### Generate compile_commands.json for LSP
```bash
make compile-commands
```

This generates `compile_commands.json` for LSP tools like clangd (used by Neovim, VSCode, etc.). This file tells your editor where to find headers and how the project is compiled.

**Prerequisites**: Install Bear (Build EAR)
```bash
brew install bear  # macOS
```

Run this command after cloning the repo or when adding/removing source files to refresh LSP configuration.

## Project Structure

```
trimui-brick-cpp-template/
├── src/              # Source files (.cpp)
├── include/          # Header files (.h)
├── lib/              # Third-party header-only libraries
├── assets/           # Resources (fonts, images, etc.)
├── scripts/          # Build and deployment scripts
├── Makefile          # Build system
├── Dockerfile        # Cross-compilation environment
└── README.md         # This file
```

## Configuration

### Using Environment Variables (Recommended)

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` with your device settings:
```bash
# Project configuration
PROJECT_NAME=my-brick-app
PAK_NAME=my-brick-app.pak

# Brick connection settings
BRICK_IP=192.168.0.142
BRICK_PASS=tina
FTP_USER=minui:minui
```

The `.env` file is gitignored and won't be committed to version control.

**Note**: Both the Makefile and deploy script read `PROJECT_NAME` from `.env`, ensuring consistent binary naming across build and deployment.

### Alternative: Edit Makefile Directly

If not using `.env`, edit the `PROJECT_NAME` variable in `Makefile`:
```make
PROJECT_NAME ?= my-brick-app
```

## Input Mapping

The template includes joystick and keyboard input handling:

### TrimUI Brick (Joystick)
- D-pad: SDL_JOYHATMOTION
- A button: Button 1
- B button: Button 0
- X button: Button 3
- Y button: Button 2

### Development (Keyboard)
- Arrow keys: Navigation
- Enter: Confirm/Select
- Escape: Back/Exit

## Adding Dependencies

### Header-only Libraries
Place in `lib/` directory and include directly:
```cpp
#include "library.h"
```

### SDL2 Libraries
The Docker image includes SDL2 and SDL2_ttf. For additional SDL2 libraries, modify `Dockerfile`:
```dockerfile
RUN apt-get install -y libsdl2-mixer-dev:arm64
```

## Deployment Structure

The deployment creates a PAK folder on the Brick:

```
/mnt/SDCARD/Tools/tg5040/my-brick-app.pak/
├── launch.sh                # Entry point
├── my-brick-app            # ARM64 binary
└── assets/                 # Your assets
```

The app appears in the Tools menu on the Brick.

## Troubleshooting

### View Debug Output
SSH into the Brick and check the debug log:
```bash
ssh root@192.168.0.142
cat /mnt/SDCARD/Tools/tg5040/my-brick-app.pak/debug.log
```

### Deployment Requirements
The deployment script requires:
- `sshpass` for SSH commands: `brew install sshpass` (macOS)
- `curl` for FTP transfers (usually pre-installed)

### Rebuild Docker Image
If you modify the Dockerfile:
```bash
make docker-build
```

### SDL2 Not Found (macOS)
Ensure pkg-config can find SDL2:
```bash
pkg-config --cflags --libs sdl2
```

## Screen Resolution

TrimUI Brick display: 1024x768

## License

This template is provided as-is for use in your own projects.
