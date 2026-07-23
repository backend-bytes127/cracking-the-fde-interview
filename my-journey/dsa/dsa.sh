#!/bin/bash
# Usage:
#   ./dsa.sh listen                           — start competitive-companion listener
#   ./dsa.sh new cp <num> <name> <url>        — create CP files + download tests
#   ./dsa.sh new faang <num> <name> <url>     — create FAANG/LC files
#   ./dsa.sh test <file>                      — test solution against samples
#   ./dsa.sh submit <file> <url>              — submit to Codeforces
#   ./dsa.sh push                             — git commit + push after solving

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

WEEK=$(python3 -c "
from datetime import date
start = date(2026, 7, 22)
today = date.today()
print((today - start).days // 7 + 1)
")
WEEK_LABEL="week-$(printf '%02d' $WEEK)"

case "$1" in

  # ── listen ─────────────────────────────────────────────────────────────
  listen)
    python3 "$SCRIPT_DIR/listen.py"
    ;;

  # ── new ────────────────────────────────────────────────────────────────
  new)
    TRACK="$2"; NUM="$3"; NAME="$4"; URL="$5"
    if [ -z "$TRACK" ] || [ -z "$NUM" ] || [ -z "$NAME" ] || [ -z "$URL" ]; then
      echo "Usage: ./dsa.sh new <cp|faang> <num> <name> <url>"
      exit 1
    fi

    WEEK_DIR="$SCRIPT_DIR/$TRACK/$WEEK_LABEL"
    mkdir -p "$WEEK_DIR/python" "$WEEK_DIR/cpp"

    SLUG="${NUM}-${NAME}"
    PY_FILE="$WEEK_DIR/python/${SLUG}.py"
    CPP_FILE="$WEEK_DIR/cpp/${SLUG}.cpp"
    TEST_DIR="$WEEK_DIR/tests/${SLUG}"

    if [ "$TRACK" = "faang" ]; then
      PY_TMPL="$SCRIPT_DIR/_template_lc.py"
      CPP_TMPL="$SCRIPT_DIR/_template_lc.cpp"
    else
      PY_TMPL="$SCRIPT_DIR/_template.py"
      CPP_TMPL="$SCRIPT_DIR/_template.cpp"
    fi

    cp "$PY_TMPL" "$PY_FILE"
    sed -i '' "s|# Problem:|# Problem: $NAME|" "$PY_FILE"
    sed -i '' "s|# Link:|# Link: $URL|" "$PY_FILE"

    cp "$CPP_TMPL" "$CPP_FILE"
    sed -i '' "s|// Problem:|// Problem: $NAME|" "$CPP_FILE"
    sed -i '' "s|// Link:|// Link: $URL|" "$CPP_FILE"

    mkdir -p "$TEST_DIR"
    if [ "$TRACK" = "cp" ]; then
      echo "Downloading test cases..."
      oj download --directory "$TEST_DIR" "$URL" 2>&1 | grep -E "(sample|error|ERROR|✓|×)" || true
    fi

    echo ""
    echo "  track → $TRACK"
    echo "  py    → $PY_FILE"
    echo "  cpp   → $CPP_FILE"
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
    # tests/ lives two levels up from the language folder (cp/week-01/python/file.py → cp/week-01)
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
    REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    cd "$REPO_ROOT"

    git add my-journey/dsa/cp/ my-journey/dsa/faang/ my-journey/TRACKER.md my-journey/weekly-log/ 2>/dev/null || true

    MSG="${2:-solve: week ${WEEK}}"
    git commit -m "$MSG"
    git push origin main
    echo "Pushed."
    ;;

  # ── help ───────────────────────────────────────────────────────────────
  *)
    echo ""
    echo "  ./dsa.sh listen                            Start competitive-companion listener"
    echo "  ./dsa.sh new cp    <num> <name> <url>      Create CP files + download tests"
    echo "  ./dsa.sh new faang <num> <name> <url>      Create FAANG/LC files"
    echo "  ./dsa.sh test      <file>                  Test solution against samples"
    echo "  ./dsa.sh submit    <file> <url>            Submit to judge (CP only)"
    echo "  ./dsa.sh push      [\"commit msg\"]          Commit + push to GitHub"
    echo ""
    echo "  Tracks:"
    echo "    cp/    — TLE Eliminators, Codeforces, AtCoder (stdin-based)"
    echo "    faang/ — S30 + LeetCode (class Solution templates)"
    echo ""
    ;;
esac
