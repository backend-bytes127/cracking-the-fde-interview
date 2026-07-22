#!/usr/bin/env python3
"""
Competitive Companion listener — port 27121
Open a problem in your browser, click the extension, and this script:
  - Creates .py and .cpp from templates
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
    """'A. Problem Name' → 'A-problem-name', '1. Two Sum' → '001-two-sum'"""
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


def fill_template(template: str, name: str, url: str) -> str:
    return (template
        .replace('# Problem:', f'# Problem: {name}')
        .replace('# Link:', f'# Link: {url}')
        .replace('// Problem:', f'// Problem: {name}')
        .replace('// Link:', f'// Link: {url}'))


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
        py_file  = week_dir / f"{slug}.py"
        cpp_file = week_dir / f"{slug}.cpp"
        test_dir = week_dir / "tests" / slug

        week_dir.mkdir(exist_ok=True)
        test_dir.mkdir(parents=True, exist_ok=True)

        py_tmpl  = (SCRIPT_DIR / "_template.py").read_text()
        cpp_tmpl = (SCRIPT_DIR / "_template.cpp").read_text()

        if not py_file.exists():
            py_file.write_text(fill_template(py_tmpl, name, url))

        if not cpp_file.exists():
            cpp_file.write_text(fill_template(cpp_tmpl, name, url))

        for i, test in enumerate(tests, 1):
            (test_dir / f"sample-{i}.in").write_text(test['input'])
            (test_dir / f"sample-{i}.out").write_text(test['output'])

        rel = lambda p: p.relative_to(SCRIPT_DIR.parent.parent)
        print(f"\n  Problem  : {name}")
        print(f"  URL      : {url}")
        print(f"  py       → {rel(py_file)}")
        print(f"  cpp      → {rel(cpp_file)}")
        print(f"  tests    → {len(tests)} sample(s) in {rel(test_dir)}")
        print(f"\n  Waiting for next problem...")

    def log_message(self, format, *args):  # noqa: A002
        pass  # suppress raw HTTP logs


if __name__ == '__main__':
    print(f"Listening on port {PORT}...")
    print(f"Week {get_week()} → files go to week-{get_week():02d}/")
    print(f"Open a problem and click the Competitive Companion extension.\n")
    http.server.HTTPServer(('', PORT), Handler).serve_forever()
