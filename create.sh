#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Unicode symbols
CHECK="✓"
CROSS="✗"
ARROW="→"
ROCKET="🚀"
GEAR="⚙️"
COMPUTER="💻"

clear
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                                                              ║${NC}"
echo -e "${PURPLE}║           ${CYAN}Docker Development Workspace Setup${PURPLE}                ║${NC}"
echo -e "${PURPLE}║                                                              ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to validate container name
validate_container_name() {
    if [[ $1 =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# 1. Ask for container name
echo -e "${COMPUTER} ${BLUE}Step 1: Container Configuration${NC}"
echo -e "${ARROW} Container names can only contain: ${YELLOW}a-z, 0-9, _, -${NC}"
while true; do
    echo -n -e "${CYAN}Enter container name: ${NC}"
    read CONTAINER_NAME
    if validate_container_name "$CONTAINER_NAME"; then
        echo -e "${GREEN}${CHECK} Valid container name: ${CONTAINER_NAME}${NC}"
        break
    else
        echo -e "${RED}${CROSS} Invalid container name. Use only letters, numbers, underscores, and hyphens.${NC}"
    fi
done
echo ""

# 2. Ask for CPU limit
echo -e "${GEAR} ${BLUE}Step 2: Resource Configuration${NC}"
echo -e "${ARROW} Available CPU cores: ${YELLOW}$(nproc)${NC}"
while true; do
    echo -n -e "${CYAN}Enter CPU limit (cores): ${NC}"
    read LIMIT_CPU
    if [[ $LIMIT_CPU =~ ^[0-9]+$ ]] && [ $LIMIT_CPU -gt 0 ]; then
        echo -e "${GREEN}${CHECK} CPU limit set to: ${LIMIT_CPU} cores${NC}"
        break
    else
        echo -e "${RED}${CROSS} Invalid CPU limit. Enter a positive number.${NC}"
    fi
done

# 3. Ask for RAM limit
echo -e "${ARROW} Available RAM: ${YELLOW}$(free -h | awk '/^Mem:/ {print $2}')${NC}"
while true; do
    echo -n -e "${CYAN}Enter RAM limit (e.g., 8G, 16G): ${NC}"
    read LIMIT_RAM
    if [[ $LIMIT_RAM =~ ^[0-9]+[GM]$ ]]; then
        echo -e "${GREEN}${CHECK} RAM limit set to: ${LIMIT_RAM}${NC}"
        break
    else
        echo -e "${RED}${CROSS} Invalid RAM limit. Must include G or M (e.g., 8G, 512M).${NC}"
    fi
done
echo ""

# 4. Detect CUDA driver compatibility and ask for CUDA version
echo -e "${ROCKET} ${BLUE}Step 3: CUDA Version Selection${NC}"

# Function to get driver version and supported CUDA versions
get_cuda_compatibility() {
    if command -v nvidia-smi &> /dev/null; then
        local driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
        echo -e "${ARROW} NVIDIA Driver Version: ${YELLOW}${driver_version}${NC}"
        
        # Map driver versions to CUDA compatibility (simplified)
        local driver_major=$(echo $driver_version | cut -d. -f1)
        local driver_minor=$(echo $driver_version | cut -d. -f2)
        local driver_num=$((driver_major * 100 + driver_minor))
        
        if [ $driver_num -ge 545 ]; then
            echo -e "${GREEN}+ Supports CUDA: 12.0 - 12.7${NC}"
            echo "12.7.0 12.6.0 12.5.0 12.4.0 12.3.0 12.2.0 12.1.0 12.0.0"
        elif [ $driver_num -ge 530 ]; then
            echo -e "${GREEN}+ Supports CUDA: 12.0 - 12.5${NC}"
            echo "12.5.0 12.4.0 12.3.0 12.2.0 12.1.0 12.0.0"
        elif [ $driver_num -ge 520 ]; then
            echo -e "${GREEN}+ Supports CUDA: 12.0 - 12.3${NC}"
            echo "12.3.0 12.2.0 12.1.0 12.0.0"
        else
            echo -e "${YELLOW}+ Older driver, recommending CUDA 12.1.0${NC}"
            echo "12.1.0"
        fi
    else
        echo -e "${YELLOW}nvidia-smi not found, showing all CUDA versions${NC}"
        echo "12.7.0 12.6.0 12.5.0 12.4.0 12.3.0 12.2.0 12.1.0 12.0.0"
    fi
}

echo -e "${PURPLE}┌──────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}│${NC} ${GREEN}Driver & CUDA Compatibility Check${NC}                          ${PURPLE}│${NC}"
echo -e "${PURPLE}└──────────────────────────────────────────────────────────────┘${NC}"

supported_cuda=$(get_cuda_compatibility)

echo ""
echo -e "${CYAN}Available CUDA versions for your system:${NC}"
echo -e "${YELLOW}$supported_cuda${NC}"
echo ""

while true; do
    echo -n -e "${CYAN}Enter CUDA version (e.g., 12.4.0) or 'auto' for recommended: ${NC}"
    read cuda_input
    
    if [[ $cuda_input == "auto" ]]; then
        CUDA_VERSION=$(echo $supported_cuda | awk '{print $1}')
        echo -e "${GREEN}${CHECK} Auto-selected CUDA: ${CUDA_VERSION}${NC}"
        break
    elif [[ $cuda_input =~ ^12\.[0-7]\.0$ ]]; then
        CUDA_VERSION="$cuda_input"
        echo -e "${GREEN}${CHECK} Selected CUDA: ${CUDA_VERSION}${NC}"
        break
    else
        echo -e "${RED}${CROSS} Invalid CUDA version. Use format 12.X.0 (12.0.0 to 12.7.0) or 'auto'${NC}"
    fi
done
echo ""

# 5. Show GPU usage and ask for selection
echo -e "${ROCKET} ${BLUE}Step 4: GPU Configuration${NC}"
echo -e "${PURPLE}┌──────────────────────────────────────────────────────────────┐${NC}"
if command -v nvitop &> /dev/null; then
    echo -e "${PURPLE}│${NC} ${GREEN}GPU Information (nvitop):${NC}                               ${PURPLE}│${NC}"
    echo -e "${PURPLE}└──────────────────────────────────────────────────────────────┘${NC}"
    nvitop --once
elif command -v nvidia-smi &> /dev/null; then
    echo -e "${PURPLE}│${NC} ${GREEN}GPU Information (nvidia-smi):${NC}                          ${PURPLE}│${NC}"
    echo -e "${PURPLE}└──────────────────────────────────────────────────────────────┘${NC}"
    nvidia-smi
else
    echo -e "${PURPLE}│${NC} ${YELLOW}⚠️  Neither nvitop nor nvidia-smi found${NC}                      ${PURPLE}│${NC}"
    echo -e "${PURPLE}└──────────────────────────────────────────────────────────────┘${NC}"
fi

echo ""
while true; do
    echo -n -e "${CYAN}Enter GPU numbers (e.g., 0,1 or 'all'): ${NC}"
    read GPU_INPUT
    if [[ $GPU_INPUT == "all" ]]; then
        GPU_NUMBER="all"
        echo -e "${GREEN}${CHECK} Using all available GPUs${NC}"
        break
    elif [[ $GPU_INPUT =~ ^[0-9]+(,[0-9]+)*$ ]]; then
        GPU_NUMBER="$GPU_INPUT"
        echo -e "${GREEN}${CHECK} Using GPUs: ${GPU_NUMBER}${NC}"
        break
    else
        echo -e "${RED}${CROSS} Invalid GPU selection. Use format like '0,1' or 'all'.${NC}"
    fi
done
echo ""

# 6. Copy .env.setup to .env and update with user data
echo -e "${GEAR} ${BLUE}Saving Configuration...${NC}"
cp .env.setup .env
sed -i "s/GPU_NUMBER=.*/GPU_NUMBER=$GPU_NUMBER/" .env
sed -i "s/LIMIT_CPU=.*/LIMIT_CPU=$LIMIT_CPU/" .env
sed -i "s/LIMIT_RAM=.*/LIMIT_RAM=$LIMIT_RAM/" .env
echo "CUDA_VERSION=$CUDA_VERSION" >> .env

echo -e "${GREEN}${CHECK} Configuration saved to .env${NC}"

# 7. Update docker-compose.yaml container name
sed -i "s/container_name:.*/container_name: $CONTAINER_NAME/" docker-compose.yaml
echo -e "${GREEN}${CHECK} Updated container name in docker-compose.yaml${NC}"

echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                    ${YELLOW}Final Configuration${PURPLE}                     ║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC} Container: ${GREEN}$CONTAINER_NAME${NC}$(printf "%*s" $((51 - ${#CONTAINER_NAME})) "")${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC} CPU Limit: ${GREEN}$LIMIT_CPU cores${NC}$(printf "%*s" $((44 - ${#LIMIT_CPU})) "")${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC} RAM Limit: ${GREEN}$LIMIT_RAM${NC}$(printf "%*s" $((51 - ${#LIMIT_RAM})) "")${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC} CUDA Version: ${GREEN}$CUDA_VERSION${NC}$(printf "%*s" $((46 - ${#CUDA_VERSION})) "")${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC} GPUs: ${GREEN}$GPU_NUMBER${NC}$(printf "%*s" $((56 - ${#GPU_NUMBER})) "")${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 8. Start docker-compose (reads .env automatically)
echo -e "${ROCKET} ${BLUE}Starting Docker Compose...${NC}"
echo -e "${YELLOW}Building and starting container...${NC}"
docker compose up --build -d

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  ${ROCKET} Container started successfully! ${ROCKET}                    ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  ${CYAN}To connect: ${YELLOW}docker exec -it $CONTAINER_NAME bash${GREEN}$(printf "%*s" $((20 - ${#CONTAINER_NAME})) "")║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"