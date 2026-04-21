#!/bin/bash

# ==========================================================
# ServicePulse - Linux Service Monitoring Utility
# Commands:
#   servicepulse all
#   servicepulse nginx
#   servicepulse add nginx
#   servicepulse del nginx
#   servicepulse heal nginx
#   servicepulse summary
# ==========================================================

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------- Paths ----------
BASE_DIR="/opt/servicepulse"
DATA_FILE="$BASE_DIR/services.list"
LOG_FILE="$BASE_DIR/servicepulse.log"

mkdir -p "$BASE_DIR"
touch "$DATA_FILE"
touch "$LOG_FILE"

# ---------- Helpers ----------
print_header() {
    printf "\n%-25s %-15s %-15s\n" "SERVICE" "STATUS" "UPTIME"
    printf "%-25s %-15s %-15s\n" "-------------------------" "--------------" "--------------"
}

log_event() {
    echo "$(date '+%F %T') | $1" >> "$LOG_FILE"
}

get_uptime() {
    local svc="$1"
    systemctl show "$svc" --property=ActiveEnterTimestamp --value 2>/dev/null | awk '
    {
        cmd="date -d \""$0"\" +%s"
        cmd | getline start
        close(cmd)
        now=systime()
        diff=now-start
        mins=int(diff/60)
        hrs=int(mins/60)
        days=int(hrs/24)

        if(days>0) print days "d"
        else if(hrs>0) print hrs "h"
        else print mins "m"
    }'
}

check_service() {
    local svc="$1"

    if ! systemctl list-unit-files | grep -q "^${svc}\.service"; then
        printf "%-25s ${YELLOW}%-15s${NC} %-15s\n" "$svc" "NOT FOUND" "-"
        return 1
    fi

    status=$(systemctl is-active "$svc" 2>/dev/null)

    if [[ "$status" == "active" ]]; then
        uptime=$(get_uptime "$svc")
        printf "%-25s ${GREEN}%-15s${NC} %-15s\n" "$svc" "RUNNING" "$uptime"
        return 0
    else
        printf "%-25s ${RED}%-15s${NC} %-15s\n" "$svc" "DOWN" "-"
        return 1
    fi
}

heal_service() {
    local svc="$1"

    status=$(systemctl is-active "$svc" 2>/dev/null)

    if [[ "$status" == "active" ]]; then
        echo -e "${GREEN}$svc is already running.${NC}"
        return
    fi

    echo -e "${YELLOW}Attempting restart of $svc...${NC}"
    systemctl restart "$svc"

    sleep 2

    if systemctl is-active "$svc" &>/dev/null; then
        echo -e "${GREEN}$svc recovered successfully.${NC}"
        log_event "$svc restarted successfully"
    else
        echo -e "${RED}Failed to recover $svc.${NC}"
        log_event "$svc recovery failed"
    fi
}

summary() {
    local total=0
    local running=0
    local down=0

    while read -r svc; do
        [[ -z "$svc" ]] && continue
        ((total++))
        if systemctl is-active "$svc" &>/dev/null; then
            ((running++))
        else
            ((down++))
        fi
    done < "$DATA_FILE"

    echo ""
    echo "========== SUMMARY =========="
    echo "Total Services : $total"
    echo "Running        : $running"
    echo "Down           : $down"
    echo "============================="
}

usage() {
    echo ""
    echo "Usage:"
    echo "  servicepulse all"
    echo "  servicepulse nginx"
    echo "  servicepulse add nginx"
    echo "  servicepulse del nginx"
    echo "  servicepulse heal nginx"
    echo "  servicepulse summary"
    echo ""
}

# ---------- Main ----------
case "$1" in

all)
    print_header
    while read -r svc; do
        [[ -z "$svc" ]] && continue
        check_service "$svc"
    done < "$DATA_FILE"
    ;;

add)
    if [[ -z "$2" ]]; then usage; exit 1; fi

    if grep -Fxq "$2" "$DATA_FILE"; then
        echo "$2 already exists."
    else
        echo "$2" >> "$DATA_FILE"
        echo "$2 added successfully."
        log_event "$2 added to monitoring list"
    fi
    ;;

del)
    if [[ -z "$2" ]]; then usage; exit 1; fi

    sed -i "/^$2$/d" "$DATA_FILE"
    echo "$2 removed successfully."
    log_event "$2 removed from monitoring list"
    ;;

heal)
    if [[ -z "$2" ]]; then usage; exit 1; fi
    heal_service "$2"
    ;;

summary)
    summary
    ;;

"")
    usage
    ;;

*)
    print_header
    check_service "$1"
    ;;

esac
