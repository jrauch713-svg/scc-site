#!/usr/bin/env bash
# Checks for the public site (v2, built from the design canvas). From the repo root: bash tests/site.test.sh
# Scout's section left the home page by Josh's decision (2026-10-28), so its old checks are gone with it.
set -u
pass=0; fail=0
ok()  { echo "PASS $1"; pass=$((pass+1)); }
bad() { echo "FAIL $1"; fail=$((fail+1)); }
chk() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }
PAGES="index.html services.html pricing.html about.html contact.html privacy.html"
for F in $PAGES; do
  chk "$F exists"                        "[[ -f $F ]]"
  chk "$F has viewport for phones"       "grep -q 'name=\"viewport\"' $F"
  chk "$F has a title"                   "grep -q '<title>.*Spring Cleaning Crew' $F"
  chk "$F has no bracketed placeholders" "! grep -qE '\\[[^]]{1,60}\\]' $F"
  chk "$F has no scripts or trackers"    "! grep -qi '<script' $F"
  chk "$F has no design-tool leftovers"  "! grep -qE '\\{\\{|dc\\.html|support\\.js|<x-dc|<helmet' $F"
  chk "$F makes no unproven claims"      "! grep -qiE 'licensed|insured|same[- ]day|5 stars|[0-9.]+/5|reviews from' $F"
  chk "$F offers a free estimate"        "grep -qi 'free estimate' $F"
  chk "$F menu links every main page"    "for P in services pricing about contact; do grep -q \"href=\\\"\$P.html\\\"\" $F || exit 1; done"
  chk "$F footer links home and privacy" "grep -q 'href=\"index.html\"' $F && grep -q 'href=\"privacy.html\"' $F"
  chk "$F marks itself as the current page" "[[ $F == index.html ]] || grep -q \"href=\\\"$F\\\" class=\\\"on\\\" aria-current=\\\"page\\\"\" $F"
  chk "$F shows the business email"      "grep -q 'mailto:quotes@thespringcleaningcrew.com' $F"
  chk "$F has its own description"       "grep -q '<meta name=\"description\"' $F"
done
chk "every page has a different description" "[[ \$(grep -h '<meta name=\"description\"' $PAGES | sort -u | wc -l) -eq \$(echo $PAGES | wc -w) ]]"
chk "pages are built from src/ (no hand edits)" "python3 -I src/build.py --check"
chk "about page tells Josh's story"      "grep -q 'appreciate your business' about.html && grep -q \"Hey, I'm Josh\" about.html"
chk "privacy page says no cookies or tracking" "grep -qi 'no cookies' privacy.html && ! grep -qi '<script' privacy.html"
chk "sitemap lists every page"           "for P in $PAGES; do grep -q \"thespringcleaningcrew.com/\${P/index.html/}<\" sitemap.xml || exit 1; done"
chk "robots.txt points to the sitemap"   "grep -qx 'Sitemap: https://thespringcleaningcrew.com/sitemap.xml' robots.txt"
chk "contact email present"              "grep -q 'mailto:quotes@thespringcleaningcrew.com' index.html"
chk "personal Gmail no longer shown"     "! grep -q 'thespringcleaningcrew@gmail.com' $PAGES"
chk "texting offered only with a real number" "! grep -qiE 'text (us|or|me)|text:|by text|texting' index.html || grep -qE 'href=\"(tel|sms):\\+?[0-9]' index.html"
chk "home links to pricing"              "grep -q 'href=\"pricing.html\"' index.html"
chk "badge image the home page uses is in the repo" "grep -q 'src=\"badge.webp\"' index.html && [[ -s badge.webp ]]"
chk "badge has a text description"       "grep -qE 'class=\"badge\"[^>]* alt=\"[^\"]{20,}\"' index.html"
chk "pricing links back home"            "grep -q 'href=\"index.html' pricing.html"
chk "Scout is not on the home page"      "! grep -qi 'scout' index.html"
chk "no receipt promise (Josh, 2026-11-06)" "! grep -qi 'receipt' $PAGES"
chk "photo gets an estimate, the firm quote comes in person" "grep -q 'firm quote' index.html && ! grep -qi 'straight price' index.html"
echo "passed $pass, failed $fail"
[[ $fail -eq 0 ]]
