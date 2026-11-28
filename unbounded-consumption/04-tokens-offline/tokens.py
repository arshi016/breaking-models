"""Lab 04 · Characters aren't tokens, and chats snowball.

Runs offline after one download of the tokenizer file. No API key, no cost.
Counts use the GPT-4o tokenizer (o200k_base). Other models count a little differently,
but the pattern is the same.

    python tokens.py                      # the four demos
    python tokens.py "any text you like"  # count your own text
"""
import sys

import tiktoken

enc = tiktoken.get_encoding("o200k_base")  # GPT-4o's tokenizer


def count(text: str) -> int:
    return len(enc.encode(text))


def show(rows, head=("Text", "Characters", "Tokens")):
    width = max(len(head[0]), *(len(r[0]) for r in rows))
    print(f"  {head[0]:<{width}}  {head[1]:>10}  {head[2]:>8}")
    for label, chars, toks in rows:
        print(f"  {label:<{width}}  {chars:>10,}  {toks:>8,}")
    print()


def demo_same_meaning():
    print("1 · Same meaning, different bill")
    lines = ["Hello, how are you?", "Namaste, aap kaise ho?", "नमस्ते, आप कैसे हो?"]
    show([(t, len(t), count(t)) for t in lines])
    old = tiktoken.get_encoding("cl100k_base")  # the older GPT-4 tokenizer
    print(f"  The Hindi line on the older tokenizer: {len(old.encode(lines[2]))} tokens.\n")


def demo_character_limit():
    print("2 · A 100-character limit is not a token limit")
    rows = []
    for label, ch in [("the letter a", "a"), ("🔥 fire emoji", "🔥"),
                      ("🫖 teapot emoji", "🫖"), ("𓀀 Egyptian hieroglyph", "𓀀")]:
        text = ch * 100
        rows.append((f"100 × {label}", len(text), count(text)))
    show(rows, ("100 characters of…", "Characters", "Tokens"))
    print("  Same 100 characters, 30× the tokens. Even two emoji can differ 3×.\n")


def demo_snowball(turns=100, question=100, answer=300):
    print("3 · The snowball: a chat sends the whole history again on every turn")
    separate = turns * question
    chat = 0
    for n in range(1, turns + 1):
        sent = question + (n - 1) * (question + answer)  # this question + every earlier turn
        chat += sent
        if n in (1, 2, 10, 50, turns):
            print(f"  turn {n:>3}: sends {sent:>7,} input tokens")
    print(f"\n  {turns} separate questions: {separate:>10,} input tokens")
    print(f"  the same {turns} in one chat: {chat:>10,} input tokens  ({chat // separate}×)\n")


def demo_video(seconds=3600, per_second=263):
    print("4 · One upload")
    print(f"  Gemini counts {per_second} tokens for every second of video.")
    print(f"  1 hour = {seconds:,} s × {per_second} = {seconds * per_second:,} tokens, from one click.\n")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        text = " ".join(sys.argv[1:])
        show([(text if len(text) <= 40 else text[:37] + "...", len(text), count(text))])
    else:
        demo_same_meaning()
        demo_character_limit()
        demo_snowball()
        demo_video()
