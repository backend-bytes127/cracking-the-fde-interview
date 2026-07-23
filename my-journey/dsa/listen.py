#!/usr/bin/env python3
"""
Competitive Companion listener — port 27121
Open a problem in your browser, click the extension, and this script:
  - Creates .py and .cpp from templates in language subfolders
  - Infers input parsing from sample test cases
  - Saves test cases locally (gitignored)
"""

import http.server
import json
import re
from datetime import date
from pathlib import Path

PORT = 27121
SCRIPT_DIR = Path(__file__).parent
START_DATE = date(2026, 7, 22)


def get_week() -> int:
    return (date.today() - START_DATE).days // 7 + 1


def slugify(name: str) -> str:
    name = name.strip()
    match = re.match(r'^([A-Z]|\d+)\.\s*(.+)$', name)
    if match:
        prefix = match.group(1)
        title = match.group(2)
        prefix = prefix.zfill(3) if prefix.isdigit() else prefix
    else:
        prefix, title = None, name
    slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
    return f"{prefix}-{slug}" if prefix else slug


def is_int(s: str) -> bool:
    try:
        int(s)
        return True
    except ValueError:
        return False


def infer_input(tests: list) -> tuple:
    """Analyze sample input and return (py_body, cpp_body) with parsed variables."""
    if not tests:
        return "    # your logic here\n    pass", "    // your logic here"

    sample = tests[0]['input']
    lines = [l for l in sample.rstrip('\n').split('\n') if l.strip()]

    py_parts = []
    cpp_parts = []

    for i, line in enumerate(lines):
        tokens = line.split()
        sfx = str(i + 1) if i > 0 else ""

        if len(tokens) == 1:
            if is_int(tokens[0]):
                name = f"n{sfx}" if sfx else "n"
                py_parts.append(f"    {name} = int(input())")
                cpp_parts.append(f"    long long {name}; cin >> {name};")
            else:
                name = f"s{sfx}" if sfx else "s"
                py_parts.append(f"    {name} = input().strip()")
                cpp_parts.append(f"    string {name}; cin >> {name};")

        elif len(tokens) == 2:
            if all(is_int(t) for t in tokens):
                a, b = (f"a{sfx}", f"b{sfx}") if sfx else ("a", "b")
                py_parts.append(f"    {a}, {b} = map(int, input().split())")
                cpp_parts.append(f"    long long {a}, {b}; cin >> {a} >> {b};")
            else:
                a, b = (f"a{sfx}", f"b{sfx}") if sfx else ("a", "b")
                py_parts.append(f"    {a}, {b} = input().split()")
                cpp_parts.append(f"    string {a}, {b}; cin >> {a} >> {b};")

        elif all(is_int(t) for t in tokens):
            name = f"nums{sfx}" if sfx else "nums"
            py_parts.append(f"    {name} = list(map(int, input().split()))")
            cpp_parts.append(f"    // {len(tokens)} ints — adjust as needed")

        else:
            name = f"line{sfx or '1'}"
            py_parts.append(f"    {name} = input().split()")
            cpp_parts.append(f"    // mixed line {i + 1} — adjust as needed")

    py_parts.append("    # your logic here")
    cpp_parts.append("    // your logic here")

    return '\n'.join(py_parts), '\n    '.join(cpp_parts)


def build_py(name: str, url: str, py_body: str) -> str:
    tmpl = (SCRIPT_DIR / "_template.py").read_text()
    filled = (tmpl
        .replace('# Problem:', f'# Problem: {name}')
        .replace('# Link:', f'# Link: {url}'))
    return filled.replace('    pass', py_body)


def build_cpp(name: str, url: str, cpp_body: str) -> str:
    tmpl = (SCRIPT_DIR / "_template.cpp").read_text()
    filled = (tmpl
        .replace('// Problem:', f'// Problem: {name}')
        .replace('// Link:', f'// Link: {url}'))
    return filled.replace('void solve() {\n\n}', f'void solve() {{\n    {cpp_body}\n}}')


class Handler(http.server.BaseHTTPRequestHandler):

    def do_POST(self):
        body = self.rfile.read(int(self.headers.get('Content-Length', 0)))
        self.send_response(200)
        self.end_headers()
        try:
            self.handle_problem(json.loads(body))
        except Exception as e:
            print(f"\n[ERROR] {e}")

    def handle_problem(self, data: dict):
        name  = data['name']
        url   = data['url']
        tests = data.get('tests', [])

        week     = get_week()
        week_dir = SCRIPT_DIR / f"week-{week:02d}"
        slug     = slugify(name)

        py_file  = week_dir / "python" / f"{slug}.py"
        cpp_file = week_dir / "cpp"    / f"{slug}.cpp"
        test_dir = week_dir / "tests"  / slug

        (week_dir / "python").mkdir(parents=True, exist_ok=True)
        (week_dir / "cpp").mkdir(parents=True, exist_ok=True)
        test_dir.mkdir(parents=True, exist_ok=True)

        py_body, cpp_body = infer_input(tests)

        if not py_file.exists():
            py_file.write_text(build_py(name, url, py_body))

        if not cpp_file.exists():
            cpp_file.write_text(build_cpp(name, url, cpp_body))

        for i, test in enumerate(tests, 1):
            (test_dir / f"sample-{i}.in").write_text(test['input'])
            (test_dir / f"sample-{i}.out").write_text(test['output'])

        rel = lambda p: p.relative_to(SCRIPT_DIR.parent.parent)
        print(f"\n  Problem  : {name}")
        print(f"  URL      : {url}")
        print(f"  py       → {rel(py_file)}")
        print(f"  cpp      → {rel(cpp_file)}")
        print(f"  tests    → {len(tests)} sample(s)")
        print(f"\n  Waiting for next problem...")

    def log_message(self, format, *args):  # noqa: A002
        pass


if __name__ == '__main__':
    print(f"Listening on port {PORT}...")
    print(f"Week {get_week()} → week-{get_week():02d}/python/ and week-{get_week():02d}/cpp/")
    print(f"Open a problem and click the Competitive Companion extension.\n")
    http.server.HTTPServer(('', PORT), Handler).serve_forever()
