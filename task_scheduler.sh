#!/bin/bash

LOG_FILE="task_scheduler.log"
TASKS_DIR="tasks"

# Create directories if not existing
mkdir -p "$TASKS_DIR"

# Define task
define_task() {
    echo "Enter Task Name:"
    read -r TASK_NAME
    echo "Enter Command to Execute:"
    read -r TASK_COMMAND

    echo "Choose Recurring Schedule:"
    echo "1. Daily"
    echo "2. Weekly"
    echo "3. Monthly"
    read -r SCHEDULE_CHOICE

    case $SCHEDULE_CHOICE in
        1) CRON_SCHEDULE="0 0 * * *" ;;          # Every day at midnight
        2) CRON_SCHEDULE="0 0 * * 0" ;;          # Every Sunday at midnight
        3) CRON_SCHEDULE="0 0 1 * *" ;;          # First day of every month
        *) echo "Invalid choice. Exiting." && exit 1 ;;
    esac

    TASK_FILE="$TASKS_DIR/$TASK_NAME.task"
    echo -e "$CRON_SCHEDULE $TASK_COMMAND" > "$TASK_FILE"
    echo "Task '$TASK_NAME' defined and saved to $TASK_FILE"
    
    # Add task to crontab
    (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $TASK_COMMAND") | crontab -

    # Notify user via desktop notification
    notify-send "Task Defined" "Task '$TASK_NAME' has been successfully defined and scheduled."
}

define_task

