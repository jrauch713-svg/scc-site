"""Pricing page FAQ check. usage (repo root): python3 -I tests/check_faq.py

Parses the FAQPage JSON-LD on pricing.html and asserts that every question and answer also appears
word for word in the visible text, that no question or answer is invented, and that no unproven claim is made.
"""
import html, json, re, sys
from pathlib import Path

page = (Path(__file__).resolve().parent.parent / "pricing.html").read_text()
blocks = re.findall(r'<script type="application/ld\+json">(.*?)</script>', page, re.S)
assert len(blocks) == 1, f"expected one JSON-LD block, found {len(blocks)}"
data = json.loads(blocks[0])
assert data["@type"] == "FAQPage", data["@type"]
items = data["mainEntity"]
assert len(items) >= 5, "FAQ looks too short"

visible = re.sub(r"<script.*?</script>|<style.*?</style>", "", page, flags=re.S)
visible = html.unescape(re.sub(r"<[^>]+>", " ", visible))
visible = re.sub(r"\s+", " ", visible)

for item in items:
    assert item["@type"] == "Question" and item["acceptedAnswer"]["@type"] == "Answer"
    q, a = item["name"], item["acceptedAnswer"]["text"]
    assert q in visible, f"question not visible on the page: {q}"
    assert a in visible, f"answer not visible on the page: {q}"
    assert not re.search(r"licensed|insured|same[- ]day|rating|review", q + " " + a, re.I), f"unproven claim in: {q}"

print(f"FAQ ok: {len(items)} questions match the visible text")
