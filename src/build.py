"""Build the site pages from src/. usage (repo root): python3 -I src/build.py [--check]

Each src/pages/<name>.html has header lines (title:, desc:), then a '---css' block and a '---main' block.
The output goes to <name>.html at the repo root; --check exits 1 if any built page differs from the committed one.
"""
import sys, urllib.parse
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "src"
NAV = [("services.html", "Services"), ("pricing.html", "Pricing"), ("about.html", "About"), ("contact.html", "Contact")]
FOOT = [("/", "Home")] + NAV + [("privacy.html", "Privacy")]
FAVICON_SVG = ("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'><rect width='64' height='64' rx='12' fill='#8B3A14'/>"
               "<path d='M10 44V30h7v-6h6v20h4V16h8v28h4V24h7v8h8v12z' fill='#F5E7DA'/>"
               "<rect x='8' y='47' width='48' height='7' rx='1' fill='#F6D27A'/></svg>")
FAVICON = '<link rel="icon" href="data:image/svg+xml,' + urllib.parse.quote(FAVICON_SVG, safe="=:/ '") + '">'


def links(items, current):
    current = "/" if current == "index.html" else current
    return "\n".join(f'<a href="{href}"' + (' class="on" aria-current="page"' if href == current else "") + f">{label}</a>"
                     for href, label in items)


def parse(text):
    head, rest = text.split("---css\n", 1)
    css, main = rest.split("---main\n", 1)
    meta = dict(line.split(": ", 1) for line in head.strip().splitlines())
    return meta, css.strip(), main.strip()


def build(name):
    meta, css, main = parse((SRC / "pages" / name).read_text())
    out = (SRC / "layout.html").read_text()
    for key, val in (("@@TITLE@@", meta["title"]), ("@@DESC@@", meta["desc"]),
                     ("@@URLPATH@@", "" if name == "index.html" else name), ("@@FAVICON@@", FAVICON),
                     ("@@CSS@@", (SRC / "shared.css").read_text().strip()), ("@@PAGECSS@@", css),
                     ("@@NAV@@", links(NAV, name)), ("@@FOOTNAV@@", links(FOOT, name)), ("@@MAIN@@", main)):
        out = out.replace(key, val)
    return out


def main():
    check = "--check" in sys.argv
    stale = []
    for page in sorted((SRC / "pages").glob("*.html")):
        built = build(page.name)
        target = ROOT / page.name
        if check:
            if not target.exists() or target.read_text() != built:
                stale.append(page.name)
        else:
            target.write_text(built)
    if stale:
        print("out of date: " + " ".join(stale))
        sys.exit(1)


if __name__ == "__main__":
    main()
