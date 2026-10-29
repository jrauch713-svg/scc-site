#!/usr/bin/env bash
# Checks for the public site (v2, built from the design canvas). From the repo root: bash tests/site.test.sh
# Scout's section left the home page by Josh's decision (2026-10-28), so its old checks are gone with it.
set -u
pass=0; fail=0
ok()  { echo "PASS $1"; pass=$((pass+1)); }
bad() { echo "FAIL $1"; fail=$((fail+1)); }
chk() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }
for F in index.html pricing.html; do
  chk "$F exists"                        "[[ -f $F ]]"
  chk "$F has viewport for phones"       "grep -q 'name=\"viewport\"' $F"
  chk "$F has a title"                   "grep -q '<title>.*Spring Cleaning Crew' $F"
  chk "$F has no bracketed placeholders" "! grep -qE '\\[[^]]{1,60}\\]' $F"
  chk "$F has no scripts or trackers"    "! grep -qi '<script' $F"
  chk "$F has no design-tool leftovers"  "! grep -qE '\\{\\{|dc\\.html|support\\.js|<x-dc|<helmet' $F"
  chk "$F makes no unproven claims"      "! grep -qiE 'licensed|insured|same[- ]day|5 stars|[0-9.]+/5|reviews from' $F"
  chk "$F offers a free estimate"        "grep -qi 'free estimate' $F"
done
chk "contact email present"              "grep -q 'mailto:thespringcleaningcrew@gmail.com' index.html"
chk "texting offered only with a real number" "! grep -qiE 'text (us|or|me)|text:|by text|texting' index.html || grep -qE 'href=\"(tel|sms):\\+?[0-9]' index.html"
chk "home links to pricing"              "grep -q 'href=\"pricing.html\"' index.html"
chk "pricing links back home"            "grep -q 'href=\"index.html' pricing.html"
chk "Scout is not on the home page"      "! grep -qi 'scout' index.html"
chk "photo gets an estimate, the firm quote comes in person" "grep -q 'firm quote' index.html && ! grep -qi 'straight price' index.html"
echo "passed $pass, failed $fail"
[[ $fail -eq 0 ]]
