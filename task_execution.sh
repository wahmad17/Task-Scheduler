#!/bin/bash

LOG_FILE="task_execution.log"
RETRY_COUNT=3

execute_task() {
    local TASK_NAME="$1"
    local TASK_COMMAND="$2"
    local RETRIES=0
    local SUCCESS=0

    while [ $RETRIES -lt $RETRY_COUNT ]; do
        echo "Executing Task: $TASK_NAME - Attempt $(($RETRIES + 1))" >> "$LOG_FILE"
        eval "$TASK_COMMAND"
        if [ $? -eq 0 ]; then
            SUCCESS=1
            break
        fi
        RETRIES=$(($RETRIES + 1))
        sleep 5
    done

    if [ $SUCCESS -eq 1 ]; then
        echo "Task '$TASK_NAME' completed successfully." >> "$LOG_FILE"
        notify_user "$TASK_NAME" "success"
    else
        echo "Task '$TASK_NAME' failed after $RETRY_COUNT retries." >> "$LOG_FILE"
        notify_user "$TASK_NAME" "failure"
    fi
}

notify_user() {
    local TASK_NAME="$1"
    local STATUS="$2"

    # Customize the notification message
    if [ "$STATUS" == "success" ]; then
        notify-send "Task Completed Successfully" "The task '$TASK_NAME' was executed successfully."
    else
        notify-send "Task Failed" "The task '$TASK_NAME' failed after multiple retries. Please check the logs."
    fi
}

# Example usage: execute_task "ExampleTask" "ls -l /invalid/path"

