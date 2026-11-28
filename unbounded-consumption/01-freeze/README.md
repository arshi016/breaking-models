# 01 · Freeze: a safety filter that freezes your phone

Open `index.html` in any browser, or use the live page:
https://arshi016.github.io/breaking-models/unbounded-consumption/01-freeze/

The page checks your prompt with Chai Company's filter, `^(\w+\s?)*$`.
Tap "Check my prompt". The default prompt is 27 letters and a "!".
Before the filter says no, it tries every way to split the letters into words: 2^26, about 67 million ways.
Each extra letter doubles that.

"Use fixed filter" runs `^[\w\s]*$`, which reads each character once.

Nothing is sent anywhere: the check runs in your browser. Chai Company is fictional.
