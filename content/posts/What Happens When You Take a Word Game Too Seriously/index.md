+++
title = "What Happens When You Take a Word Game Too Seriously"
date = 2026-05-16
draft = false
tags = ["code"]
+++

There’s a word game on Roblox called **Last Letter**. The premise is simple: a group of players sits around a table, almost like Russian roulette. The game gives you a starting letter, someone types a word, and the next player has to continue from the ending of that word.

In the first round, only the last letter matters:

- _apple_ → **e** → _eagle_

In the second round, the overlap gets longer:

- _eagle_ → **le** → _levy_

By the third round:

- _levy_ → **vy** → _vying_

By the fourth round, you're inheriting endings like **ing**, and the timer has shrunk from fifteen seconds to five.

It sounds manageable.

## The “Dummkopf” Incident

Learning the history of linguistics in college didn't teach me many practical skills, but it did teach me one thing that mattered: how to look for the edges of a language. The weird exceptions. The borrowed words that never quite fit. At some point, that instinct found its way into Last Letter.

I stopped trying to play the game _well_ and started trying to play it _mean_.

I figured this out the way most things click: through _embarrassment_, then _curiosity_.

I was playing normally when I typed _dummkopf_ in a round-four match. German for "dumb head." The kind of word you pick up from old war movies and never expect to use in Roblox.

I half-expected the game to reject it.

It didn't.

It accepted the word and handed my opponent the suffix **pf**.

Try thinking of an English word that starts with **pf**.

Go ahead. I'll wait.

The sound barely fits in an English mouth. There's _pfft_, which is more a noise than a word. There's _pfennig_, an old German coin, which the game also accepts.

That's basically it.

I had accidentally built a perfect trap without realizing it.

Then I started looking for more.

- _Kuvasz_, a Hungarian dog breed, leaves **sz**.
- _Yangtze_ leaves **tze**.
- Three-letter rounds open up stranger endings like **tzi**, **dae**, and **mni**.

The kind of stuff that practically requires a hobbyist interest in obscure etymology.

Four-letter rounds got even worse.

Greek endings like **odon** and **opod**, borrowed from fossil names, can back opponents into a corner. Find a word starting with _odon_. Without preparation, most people can't.

Some of these are buried in ordinary dictionaries if you're willing to dig. What surprised me was what the game knew that _wasn't_ in anything I'd checked.

I'd been testing words against public sources, bouncing between Merriam-Webster, Wiktionary, and spelling bee lists, trying to map the edges of the game's vocabulary. Most of the time, the pattern held.

Then I found _okshoofd_.

It's a unit of liquid measurement. Wiktionary traces it back to Middle Dutch in 1475. It's not in standard Merriam-Webster. It's not in any spelling bee list I'd seen. For all practical purposes, it survives as a dictionary entry for a word nobody has used in centuries.

The game accepted it.

More importantly, _okshoofd_ ends in **fd**.

So I went looking for words that also end in **fd** and found _transfd_, a non-standard abbreviation of _transferred_ buried in Merriam-Webster's abbreviations appendix.

The game accepted that too.

Which opened another door.

The game accepts non-standard abbreviations. Crazy, I know.

- _bkcy_ → bankruptcy
- _bkgd_ → background

Meaning if you play _yrbk_ (yearbook) or _nabk_ (a type of tree), your opponent inherits **bk**, and the answer turns out to be a bankruptcy abbreviation.

The game's dictionary is huge. Somewhere north of 480,000 words. We're talking Merriam-Webster Unabridged territory, not the roughly 200,000-word college edition most people mean when they say "the dictionary."

But it wasn't exactly the Unabridged either.

Some words from the Unabridged were rejected. Some words accepted by the game didn't seem to exist anywhere obvious. And since Merriam-Webster Unabridged isn't open source, it couldn't be the direct source anyway.

The closest match I found was [dwyl/english-words](https://github.com/dwyl/english-words). A flawed plain text file of 479,000 English words, hosted on GitHub. Jackpot.

The next part gets technical. If you're here for the takeaway, skip ahead to [What I Actually Learned](#what-i-actually-learned).

## Clever for About an Hour

The first version of what became Letter Demon was embarrassingly simple: a Python lookup tool with a bare-bones window, an input box, a button, and a list of results. Type a prefix, get every matching word.

![The first lookup tool](image.jpg?width=300)

The problem was that it worked too slowly.

Scanning nearly half a million words one by one doesn't sound expensive until you're staring at a five-second timer. By the time the results appeared, half your thinking time was already gone.

So I rebuilt the lookup using binary search.

If you've ever looked up a word in a physical dictionary, you've probably used the same idea without realizing it. You don't start on page one and read forward. You open somewhere near the middle, check whether you've gone too far, cut the remaining search space in half, and repeat until you land where you need to be.

The code ended up being surprisingly small:

```python
def search_starts(words, query):
    lo = bisect.bisect_left(words, query)
    hi = bisect.bisect_right(words, query + "~")  # "~" sorts after any letter — clean upper bound
    return words[lo:hi]
```

Instead of checking all 479,000 entries, the search only needs around 38 comparisons. Instant.

Suffix matching worked differently. The engine only used binary search for prefixes. Trap scoring happened afterward by checking each candidate word's ending against a list of known handwritten traps.

That solved the lookup problem but it didn't solve the workflow problem. I was still alt-tabbing out of Roblox, typing prefixes by hand, picking a word, then tabbing back and typing it before the timer ran out.

At some point I realized I was spending more effort operating the tool than playing the game. So naturally, I made the next terrible decision.

I started building something that could play for me and that project eventually became Letter Demon.

## Here Comes the Demon

I named it that because “Word Assistant” was too honest.

![Letter Demon](image-1.jpg)

Letter Demon doesn't just suggest words. It finds a valid word, types it out automatically, then waits for the next round. Like any good demon, it only shows up when it's invited.

### The Dictionary’s Soul

The first real problem showed up almost immediately.

Every time I launched the tool, it had to load a dictionary containing nearly 500,000 words. For a quick script, waiting a second isn't a big deal. For something you're actively using between rounds, it feels sluggish. I wanted the tool to feel instant.

So I added a cache:

```python
def load_wordlist_from_dict(dict_path):
    cache_path = get_cache_path(dict_path)

    # Is the cache file newer than the dictionary?
    if _cache_is_valid(cache_path, dict_path):
        with open(cache_path, "r", encoding="utf-8") as f:
            wordlist = f.read().splitlines()
        return wordlist, True

    # Parse from scratch and save for next time
    words_set = _load_dict_file(dict_path)
    wordlist = sorted(words_set)

    with open(cache_path, "w", encoding="utf-8") as f:
        f.write("\n".join(wordlist))

    return wordlist, False
```

The cache ended up being the easy part. I didn't bother with hashes or anything fancy, just file modification times. If the dictionary hadn't changed, use the cached version. If it had, rebuild it.

That alone cut startup time from about a second to around 50 milliseconds, which was more than good enough. What I almost missed, though, was that the dictionary by itself wasn't very useful.

The dictionary could tell me what words existed. The **trap list** told me which ones would ruin someone's day.

### The Trap List: My Secret Sauce

Letter Demon tries to find words that end in suffixes that are _nightmares_ to continue from.

That list, `trap_endings.txt`, is entirely hand-curated. Every entry on it got there the same way: either I trapped someone with it, or someone trapped me.

Whenever I found a suffix that consistently made people freeze, I'd write it down. Whenever I got blindsided by one myself, I'd write that down too.

Over time, the list became less of a text file and more of a catalog of accumulated pain. Each entry is a suffix that's unusually difficult to continue from. If a word ends with one of these letter combinations, the next player inherits it and has to find a valid word that starts with it.

Most people can find a word starting with **ing**. Far fewer can find one starting with **ocy**, **loh**, **xo**, **tze**, **sz**, or **odon** while a five-second timer is counting down.

That's what makes these suffixes so effective. The solutions often exist, but they're obscure enough that most players won't know them, and the timer is too short to go hunting for answers.

```
ocy
loh
xo
sz
tze
odon
opod
trak
...
```

Every time an opponent got stuck on a suffix, or every time I got stuck myself, I'd write it down.

Some traps are stronger than others. Generally, the longer the suffix, the more devastating it becomes. By round four, your opponent has to find a word starting with all four letters, which quickly turns obscure endings into dead ends.

The scoring itself is dead simple:

```python
def _trap_score(self, word: str) -> int:
    lower = word.lower()
    # Walk backward through suffix lengths, longest first — longer traps score higher
    for length in range(min(len(lower), max_len), 1, -1):
        if lower[-length:] in ending_scores:
            return ending_scores[lower[-length:]]
    return 0  # No known trap suffix — this word is polite
```

The scoring isn't actually based on suffix length. It's based on position.

The first entry in `trap_endings.txt` gets the highest score, the second gets the next highest, and so on. That means a suffix like `odon` can outrank `sz` if I've decided it's more effective in practice.

The code still checks longer suffixes first so they take priority when multiple matches are possible, but the actual score comes from the ordering of the list itself.

When I switch to **Trap** mode, the engine scans every candidate word, checks whether its ending appears in the trap list, and picks the most painful option available. If several words share the highest score, it chooses one at random. That keeps the results varied, even though they're all trying to accomplish the same thing.

If the dictionary knows _Yangtze_ and the trap list knows `tze`, things get interesting. A normal word finder would see thousands of valid words starting with **tze** and stop there. Problem solved.

Letter Demon keeps going.

It isn't trying to find a solution. It's trying to find the solution most likely to leave the next player stranded again. One of those words is _tzetze_. And what does _tzetze_ end with?

`tze`.

That's the entire idea behind the system. The dictionary provides the vocabulary. The trap list provides the intent.

### The Human Illusion

I couldn’t just rely on `keyboard.write()`. It types far too quickly and with perfect consistency. Roblox doesn’t seem to flag it as cheating, at least from what I can tell, but it never felt right. Real people don’t type with machine-like precision. We hesitate, slow down on awkward letter combinations, and occasionally pause to think.

To make the typing feel more human, I used a log-normal distribution for the delay between keypresses. Human reaction times aren't evenly distributed. Most keystrokes happen around a typical speed, but every so often there's a noticeably longer pause. A log-normal distribution captures that behavior surprisingly well, producing typing patterns that feel much closer to how people actually type:

```python
def _next_delay(self) -> float:
    base_s = max(0.03, self.base_speed_ms / 1000.0)

    if not self.jitter_on:
        return base_s

    # scale controls the spread — higher means more variance between keypresses
    scale = (self.jitter_pct / 100.0) * 0.75
    mu = math.log(base_s)  # median delay equals base_speed_ms
    delay = random.lognormvariate(mu, scale)

    return max(0.03, delay)
```

The implementation itself is fairly simple. Every time a key needs to be pressed, the program generates a new delay value. It starts with a base typing speed, then uses a log-normal distribution to introduce variation around that speed.

Most generated delays stay close to the target typing speed, but occasionally the distribution produces longer pauses. This mirrors how people actually type. We spend most of our time at a steady pace, yet we sometimes slow down on difficult letter combinations, hesitate briefly, or lose our rhythm for a moment.

The amount of variation is controlled by a jitter setting. Higher values create a wider spread of delays, making the typing appear less consistent and more human. To avoid unrealistic results, the code also enforces a minimum delay of 30 milliseconds.

### Threading Nightmares

All of this runs in the background while a small Tkinter window stays on top of the game. The challenge is that Tkinter doesn't handle long-running or blocking operations very well. If the typing logic runs on the main thread, the entire interface becomes unresponsive until the task finishes. On the other hand, letting multiple parts of the program access shared data at the same time can create its own problems. For example, a dictionary reload could happen in the middle of a round and leave the application in an inconsistent state.

To keep everything responsive and stable, the work is split across background threads, while shared resources are protected with reentrant locks. The threads handle the typing and game logic without blocking the interface, and the locks ensure that critical data can be accessed safely even when multiple parts of the program need it at the same time.

```python
def on_play_round(self):
    with self._playing_lock:
        if self._is_playing:
            return  # Already typing — bail before we fire two words at once
        self._is_playing = True

    self.root.withdraw()  # Hide, focus Roblox

    # Kick off typing in a background thread so the UI stays alive
    threading.Thread(
        target=self._type_and_return,
        args=(completion,),
        daemon=True
    ).start()

def _type_and_return(self, completion):
    try:
        self.typer.type_text(completion)
    finally:
        with self._playing_lock:
            self._is_playing = False
        self.root.after(0, self.root.deiconify)  # Hand the UI restore back to the main thread
```

There are two locks in the project, each with a different purpose. Inside `WordEngine`, I use a reentrant lock (`RLock`). This lets one method safely call another method that also needs the same lock without getting stuck waiting for itself. The app's `_playing_lock` is much simpler. It's just a regular lock that makes sure only one typing thread can run at a time.

Another important piece is the `after(0)` call. Tkinter is very particular about threading and expects anything that changes the UI to happen on the main thread. Even if the actual work is running in a background thread, UI updates have to be handed back to Tkinter. That's exactly what `after(0)` does. It schedules the update to run on the main thread as soon as possible.

It sounds like a small detail, but it's one of those things that either works perfectly or causes mysterious crashes. Before I figured that out, I spent far longer than I'd like to admit trying to understand why the program would randomly break.

## What I Actually Learned

I never really noticed the moment I went from "huh, that's interesting" to staying up way too late fixing bugs, arguing with myself over whether "good enough" was actually good enough, and somehow overengineering a stupid macro.

Still, at the end of the day, it's a macro. A macro that helped me win more than 2,000 matches and go toe-to-toe with some of the best players in the game across online tournaments, all while flying completely under the radar.

Most people never suspected a thing. A few good players had theories. Maybe I had a word list open. Maybe a dictionary. Maybe AI. But in the later rounds, when the timer drops below five seconds, none of that really helps. You don't have time to look things up. You either know the word or you don't.

That raises an obvious question: why not just use one of the many scripts already out there?

Because none of them worked the way I wanted. Most are painfully obvious. They type too fast, too perfectly, or try so hard to look human that they end up looking suspicious in the opposite direction. Some even fake typos by hitting backspace before instantly correcting themselves. Experienced players can spot that stuff from a mile away. Eventually, they get caught.

Script injectors are a completely different level. At that point you're not trying to blend in anymore. You're just blatantly cheating, and pros knows it.

What started as a way to win games slowly turned into something else. Along the way, I kept running into ideas I'd never heard of before. Binary search was one of them. When I finally understood how it worked, my reaction was basically, "Wait, that's it? That's brilliant." That became a recurring theme throughout the project: discovering some concept I'd never seen before, then immediately wanting to learn more about it.

That's probably the biggest thing I took away from all this. If you're not a programmer and you're thinking about building something, start anyway. You don't need to know everything up front. Most of what I learned came from trying things, breaking them, and figuring out why.

Ironically, the game itself eventually stopped mattering. Once winning became automatic, it stopped being interesting. The challenge shifted from playing the game to building the tool, then testing it against real players and watching it steamroll match after match. The game became less of a competition and more of a proving ground.

Figuring out what to build, why one approach worked better than another, and how to make everything reliable ended up being more interesting than the game itself.

None of that changes what it was. This wasn't some clever strategy or a new way to play. It was cheating.

I've watched opponents freeze on a suffix, run out of time, lose a heart, and leave the table. They were probably just people trying to enjoy a few rounds after school, after work, or before bed.

I learned a lot while building it, and the technical side was genuinely interesting. But that's separate from what the project actually did. At its core, it was a tool that gave me an advantage other players didn't have. That's the simplest and most honest way to describe it.
