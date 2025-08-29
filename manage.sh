#!/bin/bash

################################################################################
#                         DOCKER DEVELOPMENT WORKSPACE MANAGER                #
################################################################################
#
# This script provides a comprehensive management interface for the Docker
# development workspace. It offers an interactive menu system to perform
# common Docker operations with visual feedback and error handling.
#
# FEATURES:
#   - Start/Stop/Restart containers
#   - Rebuild containers with fresh builds
#   - Monitor container status and resource usage
#   - View real-time logs
#   - Connect to running containers
#   - Clean up unused resources
#
# PREREQUISITES:
#   - Docker and Docker Compose installed
#   - Properly configured docker-compose.yaml
#   - Environment file (.env) created by start.sh
#
# USAGE:
#   ./manage.sh                 # Interactive menu
#   ./manage.sh start          # Direct command
#   ./manage.sh stop           # Direct command
#   ./manage.sh rebuild        # Direct command
#   ./manage.sh status         # Direct command
#   ./manage.sh logs           # Direct command
#   ./manage.sh connect        # Direct command
#   ./manage.sh clean          # Direct command
#
# CONFIGURATION:
#   The script reads configuration from:
#   - docker-compose.yaml (container definitions)
#   - .env (environment variables)
#   
#   Container name is dynamically detected from docker-compose.yaml
#
# AUTHOR: Docker Workspace Setup
# VERSION: 1.0
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Unicode symbols
CHECK="✓"
CROSS="✗"
ARROW="→"
ROCKET="🚀"
GEAR="⚙️"
COMPUTER="💻"
PLAY="▶️"
STOP="⏹️"
REFRESH="🔄"
EYE="👁️"
LOG="📋"
TERMINAL="💻"
TRASH="🗑️"

# Get container name from docker-compose.yaml
get_container_name() {
    if [ -f "docker-compose.yaml" ]; then
        grep "container_name:" docker-compose.yaml | awk '{print $2}' | tr -d '"'
    else
        echo "unknown"
    fi
}

# Check if container exists
container_exists() {
    local container_name="$1"
    docker ps -a --format "table {{.Names}}" | grep -q "^${container_name}$" 2>/dev/null
}

# Check if container is running
container_running() {
    local container_name="$1"
    docker ps --format "table {{.Names}}" | grep -q "^${container_name}$" 2>/dev/null
}

# Display header
show_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║        ${CYAN}Docker Development Workspace Manager${PURPLE}             ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Display container status
show_status() {
    local container_name=$(get_container_name)
    
    echo -e "${COMPUTER} ${BLUE}Container Status${NC}"
    echo -e "${PURPLE}┌──────────────────────────────────────────────────────────────┐${NC}"
    
    if container_exists "$container_name"; then
        if container_running "$container_name"; then
            echo -e "${PURPLE}│${NC} ${GREEN}${CHECK} Container: ${container_name} (RUNNING)${NC}$(printf "%*s" $((25 - ${#container_name})) "")${PURPLE}│${NC}"
            
            # Show resource usage if running
            local cpu_usage=$(docker stats --no-stream --format "table {{.CPUPerc}}" "$container_name" 2>/dev/null | tail -n 1 | sed 's/%//')
            local mem_usage=$(docker stats --no-stream --format "table {{.MemUsage}}" "$container_name" 2>/dev/null | tail -n 1)
            
            echo -e "${PURPLE}│${NC} ${CYAN}CPU Usage: ${YELLOW}${cpu_usage}%${NC}$(printf "%*s" $((43 - ${#cpu_usage})) "")${PURPLE}│${NC}"
            echo -e "${PURPLE}│${NC} ${CYAN}Memory: ${YELLOW}${mem_usage}${NC}$(printf "%*s" $((51 - ${#mem_usage})) "")${PURPLE}│${NC}"
        else
            echo -e "${PURPLE}│${NC} ${YELLOW}${GEAR} Container: ${container_name} (STOPPED)${NC}$(printf "%*s" $((24 - ${#container_name})) "")${PURPLE}│${NC}"
        fi
    else
        echo -e "${PURPLE}│${NC} ${RED}${CROSS} No container found${NC}                                   ${PURPLE}│${NC}"
        echo -e "${PURPLE}│${NC} ${YELLOW}Run ./start.sh to create container${NC}                      ${PURPLE}│${NC}"
    fi
    
    echo -e "${PURPLE}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Start container
start_container() {
    echo -e "${PLAY} ${BLUE}Starting Container...${NC}"
    
    if [ ! -f ".env" ]; then
        echo -e "${RED}${CROSS} No .env file found. Run ./start.sh first.${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Building and starting services...${NC}"
    docker compose up --build -d
    
    local container_name=$(get_container_name)
    if container_running "$container_name"; then
        echo -e "${GREEN}${CHECK} Container started successfully!${NC}"
    else
        echo -e "${RED}${CROSS} Failed to start container${NC}"
        return 1
    fi
}

# Stop container
stop_container() {
    echo -e "${STOP} ${BLUE}Stopping Container...${NC}"
    
    local container_name=$(get_container_name)
    if container_running "$container_name"; then
        echo -e "${YELLOW}⚠️  Warning: This will stop the running container.${NC}"
        echo -e "${YELLOW}   Any unsaved work inside the container may be lost.${NC}"
        echo -n -e "${CYAN}Continue? (y/N): ${NC}"
        read confirm
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Operation cancelled.${NC}"
            return 0
        fi
    fi
    
    docker compose down
    
    local container_name=$(get_container_name)
    if ! container_running "$container_name"; then
        echo -e "${GREEN}${CHECK} Container stopped successfully!${NC}"
    else
        echo -e "${RED}${CROSS} Failed to stop container${NC}"
        return 1
    fi
}

# Rebuild container
rebuild_container() {
    echo -e "${REFRESH} ${BLUE}Rebuilding Container...${NC}"
    
    echo -e "${RED}⚠️  DANGER: This will completely rebuild the container!${NC}"
    echo -e "${YELLOW}   - Current container will be destroyed${NC}"
    echo -e "${YELLOW}   - All data inside the container will be lost${NC}"
    echo -e "${YELLOW}   - Only mounted volumes (./src, ./cache) will persist${NC}"
    echo -n -e "${CYAN}Are you sure? Type 'rebuild' to continue: ${NC}"
    read confirm
    
    if [ "$confirm" != "rebuild" ]; then
        echo -e "${YELLOW}Operation cancelled. Type 'rebuild' exactly to confirm.${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Stopping existing container...${NC}"
    docker compose down
    
    echo -e "${YELLOW}Removing old images...${NC}"
    docker compose build --no-cache
    
    echo -e "${YELLOW}Starting fresh container...${NC}"
    docker compose up -d
    
    local container_name=$(get_container_name)
    if container_running "$container_name"; then
        echo -e "${GREEN}${CHECK} Container rebuilt successfully!${NC}"
    else
        echo -e "${RED}${CROSS} Failed to rebuild container${NC}"
        return 1
    fi
}

# View logs
view_logs() {
    local container_name=$(get_container_name)
    
    if ! container_exists "$container_name"; then
        echo -e "${RED}${CROSS} Container not found${NC}"
        return 1
    fi
    
    echo -e "${LOG} ${BLUE}Container Logs (Press Ctrl+C to exit)${NC}"
    echo -e "${PURPLE}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}│${NC} Following logs for: ${GREEN}$container_name${NC}$(printf "%*s" $((31 - ${#container_name})) "")${PURPLE}│${NC}"
    echo -e "${PURPLE}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    docker compose logs -f
}

# Connect to container
connect_container() {
    local container_name=$(get_container_name)
    
    if ! container_running "$container_name"; then
        echo -e "${RED}${CROSS} Container is not running${NC}"
        return 1
    fi
    
    echo -e "${TERMINAL} ${BLUE}Connecting to container...${NC}"
    echo -e "${GREEN}Connected to ${container_name}. Type 'exit' to disconnect.${NC}"
    echo ""
    
    docker exec -it "$container_name" bash
}

# Clean resources (project-specific only)
clean_resources() {
    echo -e "${TRASH} ${BLUE}Cleaning Project Resources...${NC}"
    
    echo -e "${RED}⚠️  DANGER: This will remove all project resources!${NC}"
    echo -e "${YELLOW}   - All containers from this project${NC}"
    echo -e "${YELLOW}   - All images built by this project${NC}"
    echo -e "${YELLOW}   - All volumes created by this project${NC}"
    echo -e "${GREEN}   ✓ Your source code in ./src will be safe${NC}"
    echo -n -e "${CYAN}Are you sure? Type 'clean' to continue: ${NC}"
    read confirm
    
    if [ "$confirm" != "clean" ]; then
        echo -e "${YELLOW}Operation cancelled. Type 'clean' exactly to confirm.${NC}"
        return 0
    fi
    
    local container_name=$(get_container_name)
    local project_name=$(basename "$(pwd)")
    
    echo -e "${YELLOW}Stopping and removing project containers...${NC}"
    docker compose down --remove-orphans
    
    echo -e "${YELLOW}Removing project images...${NC}"
    # Remove images built by this docker-compose
    docker compose down --rmi local 2>/dev/null || true
    
    echo -e "${YELLOW}Removing project volumes...${NC}"
    # Remove volumes created by this docker-compose
    docker compose down --volumes 2>/dev/null || true
    
    echo -e "${YELLOW}Removing any remaining project containers...${NC}"
    # Clean up any containers with our project name
    docker ps -a --filter "name=${container_name}" --format "{{.ID}}" | xargs -r docker rm -f 2>/dev/null || true
    
    echo -e "${GREEN}${CHECK} Project cleanup completed!${NC}"
    echo -e "${CYAN}${ARROW} Only resources from this project were removed${NC}"
}

# Show menu
show_menu() {
    echo -e "${WHITE}Available Operations:${NC}"
    echo ""
    echo -e " ${PLAY}  ${CYAN}1)${NC} Start Container"
    echo -e " ${STOP}  ${CYAN}2)${NC} Stop Container" 
    echo -e " ${REFRESH}  ${CYAN}3)${NC} Rebuild Container"
    echo -e " ${EYE}  ${CYAN}4)${NC} Show Status"
    echo -e " ${LOG}  ${CYAN}5)${NC} View Logs"
    echo -e " ${TERMINAL}  ${CYAN}6)${NC} Connect to Container"
    echo -e " ${TRASH}  ${CYAN}7)${NC} Clean Project Resources"
    echo -e " ${CROSS}  ${CYAN}8)${NC} Exit"
    echo ""
}

# Main function
main() {
    # Handle direct commands
    case "${1:-}" in
        "start") start_container; exit 0 ;;
        "stop") stop_container; exit 0 ;;
        "rebuild") rebuild_container; exit 0 ;;
        "status") show_header; show_status; exit 0 ;;
        "logs") view_logs; exit 0 ;;
        "connect") connect_container; exit 0 ;;
        "clean") clean_resources; exit 0 ;;
    esac
    
    # Interactive menu
    while true; do
        show_header
        show_status
        show_menu
        
        echo -n -e "${CYAN}Select operation (1-8): ${NC}"
        read choice
        
        echo ""
        case $choice in
            1) start_container ;;
            2) stop_container ;;
            3) rebuild_container ;;
            4) continue ;;  # Status already shown
            5) view_logs ;;
            6) connect_container ;;
            7) clean_resources ;;
            8) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}${CROSS} Invalid choice. Please select 1-8.${NC}" ;;
        esac
        
        # Always prompt to continue except for status (4) - even if operations fail
        if [ "$choice" != "4" ]; then
            echo ""
            echo -n -e "${YELLOW}Press Enter to continue...${NC}"
            read
        fi
    done
}

# Run main function with all arguments
main "$@"