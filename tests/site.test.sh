#!/usr/bin/env bash
# Checks for the public site. From the scc-site repo root: bash tests/site.test.sh
set -u
pass=0; fail=0
ok()  { echo "PASS $1"; pass=$((pass+1)); }
bad() { echo "FAIL $1"; fail=$((fail+1)); }
chk() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }
F=index.html
chk "page exists"                  "[[ -f $F ]]"
chk "has viewport for phones"      "grep -q 'name=\"viewport\"' $F"
chk "has a title"                  "grep -q '<title>The Spring Cleaning Crew' $F"
chk "contact email present"        "grep -q 'mailto:thespringcleaningcrew@gmail.com' $F"
chk "no leftover placeholders"     "! grep -qE '\\[(YOUR|CONFIRM|PHOTO)' $F"
chk "no scripts or trackers"       "! grep -qi '<script' $F"
chk "no phone number or address"   "! grep -qE '\\(?[0-9]{3}\\)?[ .-][0-9]{3}[ .-][0-9]{4}' $F"
chk "no texting promised (no phone listed)" "! grep -qiE 'text or email|by text' $F"
chk "describes Scout honestly"     "grep -q 'Never posts, replies or messages anyone on its own' $F && grep -q 'official tools and API' $F"
chk "donation runs marked future"  "grep -q 'Coming soon' $F"
echo "passed $pass, failed $fail"
[[ $fail -eq 0 ]]
