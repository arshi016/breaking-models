#!/bin/bash
# bankrupt.sh · Breaking Models · LLM06 Part 1 · "Bankrupt Chai Company" game runner
#
# Runs every prompt in a TSV file AT THE SAME TIME on gemini-3.8-flash,
# then prints a leaderboard and the "x 1M bots" bill for each prompt.
#
#   Practice run (fake numbers, no API calls):  MOCK=1 bash bankrupt.sh round1.tsv
#   Real run:                                   bash bankrupt.sh round1.tsv
#
# Needs GEMINI_API_KEY set in this terminal (export GEMINI_API_KEY=...), curl and jq (macOS 15 has both).
#
# round1.tsv = one prompt per line: handle <TAB> prompt
# Easiest way: in the responses Sheet, select the Handle and Prompt cells of the chosen rows,
# press Cmd+C, and paste into the file. Sheets puts a TAB between the two cells.

set -u
MODEL="${MODEL:-gemini-3.5-flash-lite}"   # free tier: 15 requests/min, 500/day
CAP="${CAP:-8192}"          # max_output_tokens (thinking counts inside it)
LEVEL="${LEVEL:-high}"      # thinking_level
URL="https://generativelanguage.googleapis.com/v1beta/interactions"
IN_PRICE="${IN_PRICE:-0.75}"     # $ per 1M input tokens  (default: gemini-3.8-flash, until Dec 31 2026)
OUT_PRICE="${OUT_PRICE:-3.75}"   # $ per 1M output tokens, thinking included

file="${1:-}"
if [ -z "$file" ] || [ ! -f "$file" ]; then echo "Usage: bash bankrupt.sh round1.tsv"; exit 1; fi
command -v jq >/dev/null 2>&1 || { echo "jq not found"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl not found"; exit 1; }
if [ "${MOCK:-0}" != "1" ] && [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "GEMINI_API_KEY is not set in this terminal. Run: export GEMINI_API_KEY=your_key"; exit 1
fi

round="${ROUND:-$(basename "$file" | sed 's/\.[^.]*$//')}"

# Optional live board (live-board-apps-script.txt). export BOARD_URL='https://script.google.com/macros/s/.../exec?k=...'
post_board() { [ -n "${BOARD_URL:-}" ] || return 0
  local i r
  for i in 1 2 3 4 5; do
    r="$(curl -sL --max-time 30 -H 'Content-Type: text/plain' --data-binary "$1" "$BOARD_URL" 2>/dev/null)"
    [ "$r" = "ok" ] && return 0
    sleep $(( i * 3 + RANDOM % 5 ))
  done
  echo "board: could not send a result after 5 tries" >&2; return 0; }

# One result -> board JSON (score, bill, seconds, retries)
result_json() { # $1=n
  local f="$run/$1.json" code secs tries
  code="$(cat "$run/$1.code" 2>/dev/null || echo 000)"; secs="$(cat "$run/$1.secs" 2>/dev/null || echo 0)"; tries="$(cat "$run/$1.tries" 2>/dev/null || echo 1)"
  if [ "$code" = "200" ] && jq -e '.usage' "$f" >/dev/null 2>&1; then
    jq -c --rawfile h "$run/$1.handle" --rawfile p "$run/$1.prompt" --arg s "$secs" --arg t "$tries" --argjson ip "$IN_PRICE" --argjson op "$OUT_PRICE" '
      (.usage.total_input_tokens // 0) as $i | (.usage.total_thought_tokens // 0) as $th | (.usage.total_output_tokens // 0) as $o |
      {handle:$h, prompt:$p, state:"done", input:$i, thinking:$th, output:$o,
       score:(if $i > 0 then (($th + $o) / $i * 10 | round / 10) else 0 end),
       bill:(($th + $o) * $op | round), secs:($s|tonumber), retries:(($t|tonumber) - 1), ceiling:(.status == "incomplete")}' "$f"
  else
    jq -nc --rawfile h "$run/$1.handle" --rawfile p "$run/$1.prompt" --arg c "$code" --arg t "$tries" \
      '{handle:$h, prompt:$p, state:"failed", http:$c, retries:(($t|tonumber) - 1)}'
  fi; }
run="runs/${round}-$(date +%H%M%S)${RUN_TAG:+-$RUN_TAG}"
mkdir -p "$run"
[ "${MOCK:-0}" = "1" ] && echo "(MOCK mode: fake numbers, nothing is sent to Google)"

# 1) Start every prompt at the same time
n=0
while IFS=$'\t' read -r handle prompt rest || [ -n "${handle:-}" ]; do
  handle="$(printf '%s' "${handle:-}" | tr -d '\r')"
  prompt="$(printf '%s' "${prompt:-}" | tr -d '\r')"
  [ -z "$handle" ] && continue
  case "$handle" in Handle*|handle*) continue;; esac
  if [ -z "$prompt" ]; then echo "skip: no prompt for $handle"; continue; fi
  n=$((n+1))
  printf '%s' "$handle" > "$run/$n.handle"
  printf '%s' "$prompt" > "$run/$n.prompt"
  chars=$(printf '%s' "$prompt" | wc -m | tr -d ' ')
  [ "$chars" -gt 100 ] && echo "note: #$n $handle is $chars characters (over 100)"
  (
    if [ "${MOCK:-0}" = "1" ]; then
      sleep $((RANDOM % 5 + 2))
      inp=$((RANDOM % 25 + 8)); out=$((RANDOM % 600 + 20)); th=$((RANDOM % 9000 + 100))
      if [ $((th + out)) -gt "$CAP" ]; then th=$((CAP - out)); st="incomplete"; else st="completed"; fi
      printf '{"status":"%s","usage":{"total_input_tokens":%d,"total_thought_tokens":%d,"total_output_tokens":%d}}' \
        "$st" "$inp" "$th" "$out" > "$run/$n.json"
      echo 200 > "$run/$n.code"; echo "$((RANDOM % 40 + 3)).$((RANDOM % 10))" > "$run/$n.secs"; echo 1 > "$run/$n.tries"
    else
      jq -n --arg m "$MODEL" --arg p "$prompt" --arg l "$LEVEL" --argjson c "$CAP" \
        '{model:$m, input:$p, generation_config:{thinking_level:$l, max_output_tokens:$c}}' > "$run/$n.req"
      # Retry on Google "busy" errors (429/5xx/no answer). Time ONLY the attempt that answered,
      # so the seconds = how long ChaiBot took, not how long we waited for Google.
      t=0
      while :; do
        t=$((t+1))
        w="$(curl -sS -X POST "$URL" -H "Content-Type: application/json" -H "x-goog-api-key: $GEMINI_API_KEY" \
              --data-binary @"$run/$n.req" --max-time 600 -o "$run/$n.json" -w '%{http_code} %{time_total}' 2>> "$run/$n.err")"
        code="${w%% *}"; secs="${w##* }"
        case "$code" in 429|500|502|503|504|000) [ "$t" -lt "${TRIES:-10}" ] && { sleep $((10 + RANDOM % 10)); continue; };; esac
        break
      done
      echo "$code" > "$run/$n.code"; printf '%.1f' "$secs" > "$run/$n.secs"; echo "$t" > "$run/$n.tries"
    fi
    result_json "$n" > "$run/$n.result.json"
    post_board "$(cat "$run/$n.result.json")"
    touch "$run/$n.done"
  ) &
  echo "> #$n started: $handle"
done < "$file"

if [ "$n" -eq 0 ]; then echo "No prompts found in $file"; exit 1; fi
if [ -n "${BOARD_URL:-}" ]; then
  now_ms=$(( $(date +%s) * 1000 ))
  post_board "$(for i in $(seq 1 "$n"); do jq -nc --rawfile h "$run/$i.handle" --rawfile p "$run/$i.prompt" --argjson t "$now_ms" \
    '{handle:$h, prompt:$p, state:"running", started:$t}'; done | jq -sc .)" &
  echo "   Live board: updating"
fi

# 2) Live counter while ChaiBot thinks
start=$(date +%s)
while :; do
  d=$(ls "$run"/*.done 2>/dev/null | wc -l | tr -d ' ')
  printf '\r   ChaiBot is thinking... %s of %s done · %ss   ' "$d" "$n" "$(( $(date +%s) - start ))"
  [ "$d" -ge "$n" ] && break
  sleep 2
done
echo
wait

# 3) Read the token counts
: > "$run/rows.tsv"
i=1
while [ "$i" -le "$n" ]; do
  h="$(cat "$run/$i.handle")"
  code="$(cat "$run/$i.code" 2>/dev/null || true)"
  if [ "$code" = "200" ] && jq -e '.usage' "$run/$i.json" >/dev/null 2>&1; then
    inp=$(jq -r '.usage.total_input_tokens // 0' "$run/$i.json")
    th=$(jq -r '.usage.total_thought_tokens // 0' "$run/$i.json")
    out=$(jq -r '.usage.total_output_tokens // 0' "$run/$i.json")
    st=$(jq -r '.status // "?"' "$run/$i.json")
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$h" "$inp" "$th" "$out" "$st" "$i" "$(cat "$run/$i.secs" 2>/dev/null || echo 0)" >> "$run/rows.tsv"
  else
    echo "x #$i $h failed (HTTP ${code:-none}, $(( $(cat "$run/$i.tries" 2>/dev/null || echo 1) )) tries). See $run/$i.json and $run/$i.err"
    printf '%s\t%s\n' "$h" "$(cat "$run/$i.prompt")" >> "${round}-failed.tsv"
  fi
  i=$((i+1))
done

# 4) Score, sort (higher score first; a tie goes to fewer input tokens), print
awk -F'\t' -v ip="$IN_PRICE" -v op="$OUT_PRICE" 'BEGIN{OFS="\t"}
  { inp=$2+0; th=$3+0; out=$4+0
    score = (inp > 0) ? (th + out) / inp : 0
    bill = (th + out) * op                 # one run x 1,000,000 bots, in dollars (input left out: ~$10)
    print $1, inp, th, out, score, bill, $5, $6, $7 }' "$run/rows.tsv" |
  sort -t "$(printf '\t')" -k5,5gr -k2,2n > "$run/board.tsv"

awk -F'\t' -v title="$round" '
  function commas(x,   s, o) { s = sprintf("%d", x + 0.5); o = ""
    while (length(s) > 3) { o = "," substr(s, length(s) - 2) o; s = substr(s, 1, length(s) - 3) }
    return s o }
  BEGIN { print ""; print "   BANKRUPT CHAI COMPANY · " title; print ""
          printf "   %-3s %-16s %7s %9s %7s %8s %7s %12s\n", "#", "HANDLE", "INPUT", "THINKING", "OUTPUT", "SCORE", "SECS", "x 1M BOTS" }
  { printf "   %-3s %-16.16s %7s %9s %7s %8.1f %7.1f %12s%s\n", NR, $1, commas($2), commas($3), commas($4), $5, $9, "$" commas($6), ($7 == "incomplete") ? "  hit the ceiling" : "" }
  END { print "" }' "$run/board.tsv"

# 5) Save every scored prompt for the Hall of Fame and the Dec 12 exam
while IFS=$'\t' read -r h inp th out score bill st idx secs; do
  jq -nc --arg h "$h" --arg r "$round" --rawfile p "$run/$idx.prompt" \
    --argjson i "$inp" --argjson t "$th" --argjson o "$out" --arg s "$score" --arg st "$st" --arg sec "$secs" \
    '{handle:$h, round:$r, prompt:$p, input_tokens:$i, thinking_tokens:$t, output_tokens:$o, score:(($s|tonumber)*10|round/10), seconds:($sec|tonumber), status:$st}' >> part1.jsonl
done < "$run/board.tsv"
echo "   Saved to part1.jsonl · raw answers in $run/"
[ -f "${round}-failed.tsv" ] && echo "   Some prompts failed. Re-run only them: bash $0 ${round}-failed.tsv"
