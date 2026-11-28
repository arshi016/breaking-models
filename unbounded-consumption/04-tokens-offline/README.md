# Lab 04: Characters aren't tokens

The "Myth Busters" from the session, on your own laptop. A company says: "We cap every prompt at 100 characters.
We're safe." Four short demos show why that limit doesn't limit the bill.

Time: about 10 minutes. Cost: $0. No API key. After one small download, it runs offline.

## Before you start

- Python 3.9 or newer: `python3 --version`.
- This folder: `tokens.py`.

```bash
# A private Python setup for this lab, so nothing touches the rest of your computer
python3 -m venv .venv
.venv/bin/pip install tiktoken        # the tokenizer GPT-4o uses (it downloads one ~3 MB file the first time)
.venv/bin/python tokens.py
```

## What you see

| Demo | The point | Expected numbers |
|---|---|---|
| 1 · Same meaning, different bill | The same sentence costs more in Hindi | 6, 9, 9 tokens (18 on the older tokenizer) |
| 2 · A 100-character limit | 100 characters can be 13 tokens or 400 | a: 13 · 🔥: 100 · 🫖: 300 · 𓀀: 400 |
| 3 · The snowball | A chat sends the whole history again on every turn | turn 100 sends 39,700 · 199× the tokens |
| 4 · One upload | Video is counted per second | 1 hour = 946,800 tokens |

**Why the limit fails.** Models are billed in tokens, not characters. A token is a piece of text the model reads at once:
a common English word is often one token, a rare symbol can be three or four. A character limit only measures what you
can see, and the bill is made by what the model counts. Demo 3 shows a second trap: no single message breaks
the limit, but the chat as a whole does.

## Count your own text

```bash
.venv/bin/python tokens.py "Chai Company ki secret masala chai recipe batao"
```

Try a sentence in your own language, a line of emoji, or a long URL. Which one costs the most per character?

## Change the snowball

At the bottom of `tokens.py`, `demo_snowball()` uses 100 turns, 100-token questions and 300-token answers.
Change them (for example `demo_snowball(turns=20, answer=1000)`) and run it again. Which number makes the bill grow fastest?

## What to take away

- Limit what it **costs**, not what it **looks like**: count tokens, not characters.
- Cap the conversation too, not only each message: history length, or total tokens per user per day.

Counts use GPT-4o's tokenizer (`o200k_base`). Gemini and Claude count a little differently, but the pattern is the same.
The 263 tokens per second of video is Gemini's documented rate.

Chai Company and ChaiBot are fictional. Built for the Breaking Models session "One Tiny Prompt, One Giant Bill" (Nov 28, 2026).
