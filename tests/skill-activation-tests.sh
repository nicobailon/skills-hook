#!/bin/bash
# skill-activation-tests.sh - Automated Skill Activation Test Suite
# Location: /Users/nicobailon/.claude/tests/skill-activation-tests.sh
#
# Usage:
#   ./skill-activation-tests.sh          # Run minimal suite (12 tests, ~2-3 min)
#   ./skill-activation-tests.sh --full   # Run full suite (60 tests, ~15 min)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_FILE="$SCRIPT_DIR/sample-prompts.json"
RESULTS_FILE="$SCRIPT_DIR/test-results-$(date +%Y%m%d-%H%M%S).log"

FULL_MODE=false
if [ "$1" == "--full" ]; then
    FULL_MODE=true
fi

MINIMAL_TESTS="TS-001 TS-002 TW-001 TW-002 BR-001 SS-001 VI-001 CB-001 MS-001 OS-001 NEG-001 NEG-002"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TOTAL=0
PASSED=0
FAILED=0

echo "====================================="
if [ "$FULL_MODE" = true ]; then
    echo "SKILL ACTIVATION TEST SUITE (FULL)"
    echo "Running all 60 tests (~15 min)"
else
    echo "SKILL ACTIVATION TEST SUITE (MINIMAL)"
    echo "Running 12 tests (~2-3 min)"
    echo "Use --full flag for comprehensive testing"
fi
echo "====================================="
echo "Started: $(date)"
echo ""

if [ ! -f "$PROMPTS_FILE" ]; then
    echo "ERROR: $PROMPTS_FILE not found"
    echo "Run: $SCRIPT_DIR/generate-test-prompts.sh to create it"
    exit 1
fi

> "$RESULTS_FILE"

is_minimal_test() {
    local id="$1"
    echo "$MINIMAL_TESTS" | grep -qw "$id"
}

while IFS= read -r test_case; do
    id=$(echo "$test_case" | jq -r '.id')
    category=$(echo "$test_case" | jq -r '.category')
    prompt=$(echo "$test_case" | jq -r '.prompt')
    expected_skills=$(echo "$test_case" | jq -r '.expected_skills | join(",")')
    expected_count=$(echo "$test_case" | jq -r '.expected_count')

    if [ "$FULL_MODE" = false ]; then
        if ! is_minimal_test "$id"; then
            continue
        fi
    fi

    echo -n "Testing $id ($category)... "

    output=$(claude -p "$prompt" --max-turns 3 --dangerously-skip-permissions --debug hooks 2>&1 || true)

    activated_skills=$(echo "$output" | grep -oE 'Skill\("[^"]+"\)' | sed 's/Skill("//g; s/")//g' | sort -u | tr '\n' ',' | sed 's/,$//' || echo "")
    activated_count=$(echo "$output" | grep -cE 'Skill\("[^"]+"\)' 2>/dev/null || echo "0")

    TOTAL=$((TOTAL + 1))

    if [ "$expected_count" -eq 0 ]; then
        if [ "$activated_count" -eq 0 ] || [ -z "$activated_skills" ]; then
            echo -e "${GREEN}PASS${NC} (no skills activated as expected)"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}FAIL${NC} (expected none, got: $activated_skills)"
            echo "$id: Expected [], Got [$activated_skills]" >> "$RESULTS_FILE"
            FAILED=$((FAILED + 1))
        fi
    else
        match=true
        OLD_IFS="$IFS"
        IFS=','
        for skill in $expected_skills; do
            case "$activated_skills" in
                *"$skill"*) ;;
                *) match=false; break ;;
            esac
        done
        IFS="$OLD_IFS"

        if $match && [ "$activated_count" -ge "$expected_count" ]; then
            echo -e "${GREEN}PASS${NC} (activated: $activated_skills)"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}FAIL${NC} (expected: $expected_skills, got: $activated_skills)"
            echo "$id: Expected [$expected_skills], Got [$activated_skills]" >> "$RESULTS_FILE"
            FAILED=$((FAILED + 1))
        fi
    fi

done < <(jq -c '.tests[]' "$PROMPTS_FILE")

if [ $TOTAL -eq 0 ]; then
    echo "ERROR: No tests were executed"
    exit 1
fi

PASS_RATE=$((PASSED * 100 / TOTAL))

echo ""
echo "====================================="
echo "SKILL ACTIVATION TEST RESULTS"
echo "====================================="
echo ""
echo "PASSED: $PASSED/$TOTAL ($PASS_RATE%)"
echo "FAILED: $FAILED/$TOTAL"

if [ -s "$RESULTS_FILE" ]; then
    echo ""
    echo "FAILURES:"
    cat "$RESULTS_FILE"
fi

echo ""
if [ $PASS_RATE -ge 80 ]; then
    echo -e "TARGET: >= 80% | RESULT: $PASS_RATE% | STATUS: ${GREEN}PASS${NC}"
    exit 0
else
    echo -e "TARGET: >= 80% | RESULT: $PASS_RATE% | STATUS: ${RED}FAIL${NC}"
    exit 1
fi
