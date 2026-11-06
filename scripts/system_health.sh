#!/bin/bash

# ==========================================
# System Health Monitoring Script
# DevOps Intern Assignment
# ==========================================

set -euo pipefail

# Project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Log file location
LOG_FILE="$PROJECT_DIR/health_log.txt"

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')

# ------------------------------------------
# 1. CPU Usage Calculation
# ------------------------------------------

read_cpu_stats() {
    awk '/^cpu / {
        idle = $5 + $6
        total = 0

        for (i = 2; i <= NF; i++) {
            total += $i
        }

        printf "%.0f %.0f\n", total, idle
        exit
    }' /proc/stat
}

read -r TOTAL1 IDLE1 < <(read_cpu_stats)

sleep 1

read -r TOTAL2 IDLE2 < <(read_cpu_stats)

TOTAL_DIFF=$((TOTAL2 - TOTAL1))
IDLE_DIFF=$((IDLE2 - IDLE1))

CPU_USAGE=$(awk -v total="$TOTAL_DIFF" -v idle="$IDLE_DIFF" '
BEGIN {
    if (total > 0)
        printf "%.2f", (total - idle) * 100 / total
    else
        printf "0.00"
}')

# ------------------------------------------
# 2. Memory Usage Calculation
# ------------------------------------------

MEMORY_USAGE=$(awk '
/MemTotal:/ {
    total = $2
}

/MemAvailable:/ {
    available = $2
}

END {
    if (total > 0)
        printf "%.2f", (total - available) * 100 / total
    else
        printf "0.00"
}' /proc/meminfo)

# ------------------------------------------
# 3. Disk Usage Calculation
# ------------------------------------------

DISK_USAGE=$(df -P / | awk 'NR == 2 {
    gsub("%", "", $5)
    print $5
}')

# ------------------------------------------
# 4. Create Health Report
# ------------------------------------------

REPORT="[$TIMESTAMP] CPU: ${CPU_USAGE}% | Memory: ${MEMORY_USAGE}% | Disk: ${DISK_USAGE}%"

# Print report
echo "$REPORT"

# Append report to log file
echo "$REPORT" >> "$LOG_FILE"

# ------------------------------------------
# 5. Disk Usage Warning
# ------------------------------------------

if (( DISK_USAGE > 80 )); then

    WARNING="[WARNING] Disk space high!"

    echo "$WARNING"

    echo "[$TIMESTAMP] $WARNING" >> "$LOG_FILE"

fi

echo "Health check completed successfully."
echo "Log file: $LOG_FILE"