#!/bin/bash

# Ralph Wiggum loop for trip planner destination catalogue
# Usage: ./ralph-catalogue.sh

PLAN_FILE="Plans/issue-1-build-trip-planner-destination-catalogue.md"
PROGRESS_FILE="Plans/catalogue-progress.txt"
MAX_ITERATIONS=120

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
    echo "# Trip Planner Catalogue Implementation Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "" >> "$PROGRESS_FILE"
fi

for i in $(seq 1 $MAX_ITERATIONS); do
    echo "=========================================="
    echo "Ralph iteration $i of $MAX_ITERATIONS — $(date '+%H:%M:%S')"
    echo "=========================================="

    OUTPUT=$(/Users/darrenwilson/.local/bin/claude --dangerously-skip-permissions -p "You are implementing a trip planner destination catalogue — a static Astro site serving as a modern holiday brochure for Darren and Anthony.

## Plan File
$(cat "$PLAN_FILE")

## Progress So Far
$(cat "$PROGRESS_FILE")

## Instructions
1. Review the plan and progress above
2. Identify the NEXT SINGLE incomplete task (strict order: Phase 1 Task 1 → Phase 1 Task 2 → Phase 2 Task 1 → etc.)
3. Implement ONLY that ONE task
4. Run 'npm run build' to verify it compiles (SKIP this step if: you only modified non-project files like the plan or progress file, OR you already ran tests/build as part of TDD this iteration)
5. Commit your changes
6. Write ONE log entry to $PROGRESS_FILE:
   --- Iteration $i: \$(date) ---
   Task: [task name]
   Status: [completed/in-progress/blocked]
   Changes: [files modified]
   Notes: [any notes]

7. Then STOP. Do not continue to the next task.
8. Only output <promise>COMPLETE</promise> if ALL tasks in the entire plan are done.
9. Only output <promise>BLOCKED</promise> if you cannot proceed.

## CRITICAL - DO NOT:
- Do NOT implement multiple tasks - only ONE task per iteration
- Do NOT write multiple log entries - only ONE entry with the current iteration number
- Do NOT continue after writing the log entry - STOP and let the next loop iteration start
- Do NOT say COMPLETE unless every single task in the plan is finished
- Do NOT fake or simulate multiple iterations - you are iteration $i only
- Do NOT use AI slop in content: avoid 'hidden gem', 'vibrant tapestry', 'feast for the senses', 'nestled', 'bustling', 'rich tapestry', 'mecca for', 'paradise for'
- When writing destination content, write as a well-travelled friend recommending places. Be specific — name actual streets, neighbourhoods, markets. Be honest about allergen risks.
- For Unsplash images: use real photo URLs from unsplash.com in format https://images.unsplash.com/photo-XXXXX?w=800

The bash loop will call you again for the next task. Your job is ONE task, ONE commit, ONE log entry, then STOP.")

    echo "$OUTPUT"

    # Check for completion
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo ""
        echo "=========================================="
        echo "Implementation complete!"
        echo "=========================================="
        exit 0
    fi

    # Check for blocked state
    if echo "$OUTPUT" | grep -q "<promise>BLOCKED</promise>"; then
        echo ""
        echo "=========================================="
        echo "Implementation blocked - manual intervention needed"
        echo "=========================================="
        exit 1
    fi

    # Small delay between iterations
    sleep 2
done

echo "=========================================="
echo "Max iterations reached without completion"
echo "=========================================="
exit 1
