#!/bin/bash
# Usage:
#   ./dsa.sh listen                      — start competitive-companion listener
#   ./dsa.sh new <num> <name> <url>      — create files + download test cases
#   ./dsa.sh test <file>                 — test solution against samples
#   ./dsa.sh submit <file> <url>         — submit to Codeforces/LeetCode
#   ./dsa.sh push <slug>                 — git commit + push after solving

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect current week from start date
WEEK=$(python3 -c "
from datetime import date
start = date(2026, 7, 22)
today = date.today()
print((today - start).days // 7 + 1)
")
WEEK_DIR="$SCRIPT_DIR/week-$(printf '%02d' $WEEK)"

case "$1" in

  # ── listen ─────────────────────────────────────────────────────────────
  listen)
    python3 "$SCRIPT_DIR/listen.py"
    ;;

  # ── new ────────────────────────────────────────────────────────────────
  new)
    NUM="$2"; NAME="$3"; URL="$4"
    if [ -z "$NUM" ] || [ -z "$NAME" ] || [ -z "$URL" ]; then
      echo "Usage: ./dsa.sh new <num> <name> <url>"
      exit 1
    fi

    mkdir -p "$WEEK_DIR"
    PY_FILE="$WEEK_DIR/${NUM}-${NAME}.py"
    CPP_FILE="$WEEK_DIR/${NUM}-${NAME}.cpp"
    TEST_DIR="$WEEK_DIR/tests/${NUM}-${NAME}"

    # Python — copy template and fill header
    cp "$SCRIPT_DIR/_template.py" "$PY_FILE"
    sed -i '' "s|# Problem:|# Problem: $NAME|" "$PY_FILE"
    sed -i '' "s|# Link:|# Link: $URL|" "$PY_FILE"

    # C++ — copy template and fill header
    cp "$SCRIPT_DIR/_template.cpp" "$CPP_FILE"
    sed -i '' "s|// Problem:|// Problem: $NAME|" "$CPP_FILE"
    sed -i '' "s|// Link:|// Link: $URL|" "$CPP_FILE"

    # Download test cases (*.in / *.out are gitignored)
    mkdir -p "$TEST_DIR"
    echo "Downloading test cases..."
    oj download --directory "$TEST_DIR" "$URL" 2>&1 | grep -E "(sample|error|ERROR|✓|×)" || true

    echo ""
    echo "  py  → $PY_FILE"
    echo "  cpp → $CPP_FILE"
    echo "  tests → $TEST_DIR"
    ;;

  # ── test ───────────────────────────────────────────────────────────────
  test)
    FILE="$2"
    if [ -z "$FILE" ]; then
      echo "Usage: ./dsa.sh test <file>"
      exit 1
    fi

    EXT="${FILE##*.}"
    BASENAME="$(basename "$FILE")"
    PROBLEM="${BASENAME%.*}"
    # tests live one level up from python/ or cpp/
    WEEK_DIR="$(dirname "$(dirname "$FILE")")"
    TEST_DIR="$WEEK_DIR/tests/$PROBLEM"

    if [ ! -d "$TEST_DIR" ]; then
      echo "No test cases found at $TEST_DIR"
      exit 1
    fi

    if [ "$EXT" = "py" ]; then
      oj test --command "python3 $FILE" --directory "$TEST_DIR"

    elif [ "$EXT" = "cpp" ]; then
      BIN="/tmp/${PROBLEM}"
      g++ -O2 -o "$BIN" "$FILE"
      oj test --command "$BIN" --directory "$TEST_DIR"
      rm -f "$BIN"

    elif [ "$EXT" = "rs" ]; then
      BIN="/tmp/${PROBLEM}"
      rustc -o "$BIN" "$FILE"
      oj test --command "$BIN" --directory "$TEST_DIR"
      rm -f "$BIN"
    fi
    ;;

  # ── submit ─────────────────────────────────────────────────────────────
  submit)
    FILE="$2"; URL="$3"
    if [ -z "$FILE" ] || [ -z "$URL" ]; then
      echo "Usage: ./dsa.sh submit <file> <url>"
      exit 1
    fi
    oj submit "$URL" "$FILE"
    ;;

  # ── push ───────────────────────────────────────────────────────────────
  push)
    SLUG="$2"
    if [ -z "$SLUG" ]; then
      echo "Usage: ./dsa.sh push <slug>   (e.g. J-multiples)"
      exit 1
    fi

    REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    cd "$REPO_ROOT"

    git add "my-journey/dsa/week-$(printf '%02d' $WEEK)/python/${SLUG}.py" \
            "my-journey/dsa/week-$(printf '%02d' $WEEK)/cpp/${SLUG}.cpp" \
            "my-journey/dsa/week-$(printf '%02d' $WEEK)/rust/${SLUG}.rs" 2>/dev/null || true

    git commit -m "solve: ${SLUG} — week ${WEEK}"
    git push origin main
    echo "Pushed."
    ;;

  # ── help ───────────────────────────────────────────────────────────────
  *)
    echo ""
    echo "  ./dsa.sh listen                      Start competitive-companion listener"
    echo "  ./dsa.sh new    <num> <name> <url>   Create files + download tests"
    echo "  ./dsa.sh test   <file>               Test solution against samples"
    echo "  ./dsa.sh submit <file> <url>         Submit to judge"
    echo "  ./dsa.sh push   <slug>               Commit + push to GitHub"
    echo ""
    ;;
esac
