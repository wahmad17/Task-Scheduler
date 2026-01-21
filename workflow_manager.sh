#!/bin/bash

WORKFLOW_LOG="workflow.log"

run_workflow() {
    declare -A TASKS
    declare -A DEPENDENCIES

    TASKS["task1"]="echo 'Task 1 Running'"
    TASKS["task2"]="echo 'Task 2 Running'"
    TASKS["task3"]="echo 'Task 3 Running'"

    DEPENDENCIES["task2"]="task1"
    DEPENDENCIES["task3"]="task2"

    for TASK in "${!TASKS[@]}"; do
        if [ -z "${DEPENDENCIES[$TASK]}" ] || grep -q "Success: ${DEPENDENCIES[$TASK]}" "$WORKFLOW_LOG"; then
            echo "Executing $TASK" >> "$WORKFLOW_LOG"
            eval "${TASKS[$TASK]}"
            if [ $? -eq 0 ]; then
                echo "Success: $TASK" >> "$WORKFLOW_LOG"
                notify_user "$TASK" "success"
            else
                echo "Failure: $TASK" >> "$WORKFLOW_LOG"
                notify_user "$TASK" "failure"
                break
            fi
        else
            echo "$TASK depends on ${DEPENDENCIES[$TASK]} which has not completed." >> "$WORKFLOW_LOG"
        fi
    done
}

notify_user() {
    local TASK_NAME="$1"
    local STATUS="$2"

    # Customize the notification message
    if [ "$STATUS" == "success" ]; then
        notify-send "Task Completed Successfully" "The task '$TASK_NAME' was executed successfully."
    else
        notify-send "Task Failed" "The task '$TASK_NAME' failed. Please check the workflow log for more details."
    fi
}

run_workflow

