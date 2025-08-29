# Docker Development Workspace

A containerized development environment with CUDA support, configurable resources, and interactive setup.

## Quick Start

```bash
./start.sh
```

The interactive script will guide you through:
- Container naming
- CPU/RAM limits  
- GPU selection
- Automatic container startup

## Files

- `start.sh` - Interactive setup script with colorful UI
- `docker-compose.yaml` - Container configuration with variable substitution
- `Dockerfile` - CUDA-enabled Ubuntu 22.04 with Python 3.10
- `.env.setup` - Template for environment variables
- `.env` - Generated configuration (created by start.sh)

## Configuration

Environment variables in `.env`:
```bash
GPU_NUMBER=0,1     # GPU IDs or "all"
LIMIT_CPU=4        # CPU cores
LIMIT_RAM=8G       # Memory limit (G/M suffix required)
```

## Volumes

- `./src` ’ `/app/src` (your source code)
- `./cache` ’ `/app/cache` (ML model cache, pip cache, etc.)

## Usage

1. Run `./start.sh` to configure and start
2. Connect: `docker exec -it <container-name> bash`
3. Your code in `./src` is mounted and ready to edit

## Features

- GPU support with configurable device selection
- Resource limits (CPU/RAM) 
- Host networking mode
- Persistent cache directories
- Interactive bash shell for development