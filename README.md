# Docker Development Workspace

A containerized development environment with CUDA support, configurable resources, and interactive setup.

## Quick Start

```bash
./start.sh    # Initial setup and start
./manage.sh   # Manage running containers
```

**First time setup:**
- `./start.sh` guides you through container naming, CPU/RAM limits, GPU selection
- Container starts automatically after configuration

**Daily usage:**
- `./manage.sh` provides menu for start/stop/rebuild/logs/connect

## Files

- `start.sh` - Interactive setup script with colorful UI
- `manage.sh` - Container management with start/stop/rebuild/logs
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

- `./src` � `/app/src` (your source code)
- `./cache` � `/app/cache` (ML model cache, pip cache, etc.)

## Usage

1. **First time:** `./start.sh` to configure and start
2. **Daily management:** `./manage.sh` for operations menu
3. **Quick connect:** Option 6 in manage.sh or `docker exec -it <container-name> bash`
4. **Development:** Your code in `./src` is mounted and ready to edit

**Management Operations:**
- Start/Stop containers with confirmations
- Rebuild with fresh builds  
- View real-time logs
- Monitor CPU/memory usage
- Safe project-only cleanup

## Features

- GPU support with configurable device selection
- Resource limits (CPU/RAM) 
- Host networking mode
- Persistent cache directories
- Interactive bash shell for development