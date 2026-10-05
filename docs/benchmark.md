# Benchmark: Claude Code with and without mind-palace

This was a blind A/B test on a real open-source project. It measured answer quality and token cost with the plugin (B) and without it (A).

## TL;DR

- **Continuing yesterday's work: 10.0/10 with mind-palace vs 8.3/10 without.** All three B runs scored higher than all three A runs. They followed the decisions made in the previous session, which A had no way to know.
- **One-off questions and fresh tasks: no quality difference.** The scores were within run-to-run spread.
- **Cost: +10.6% on average.** The memory lives in the context of every session, so mind-palace pays off when work spans several sessions, not on one-off questions.

## Setup

| | |
|---|---|
| Project | [pallets/click](https://github.com/pallets/click) at `2247b35` (91 Python files) |
| Runs | 5 tasks × 2 arms × 3 repetitions = 30 headless `claude -p` runs, each in a fresh copy of the repo |
| Isolation | Same model, same Claude Code version (2.1.289) and same flags in both arms. Each run had an empty HOME: no user `CLAUDE.md`, no settings, no other plugins |
| Arm A | No plugin |
| Arm B | mind-palace, plus a memory file saved by one warm-up session (explore the project, then `/mind-palace:remember`) |
| Judging | A separate judge agent scored every answer 0–10 against a checklist written before any run. Arm labels were removed and the order shuffled. For the coding tasks, the judge ran hidden tests and the full test suite; a failure would have capped the score at 3 |

## Results

| Task | Quality A | Quality B | Cost A | Cost B | Cost Δ |
|---|---|---|---|---|---|
| Codebase question: env-var resolution | 9.17 | 9.17 | $0.097 | $0.116 | +19.6% |
| Codebase question: shell completion | 9.83 | 9.50 | $0.125 | $0.130 | +4.2% |
| Explain an error | 9.17 | 9.50 | $0.055 | $0.055 | −0.9% |
| Small code change + tests | 10.00 | 9.83 | $0.092 | $0.098 | +6.2% |
| **Continue yesterday's work** | **8.33** | **10.00** | $0.097 | $0.117 | +20.6% |
| **All tasks** | **9.30** | **9.60** | $1.40 total | $1.54 total | +10.6% |

"Significant" below means every run of one arm beat every run of the other. With n=3 this is a coarse test, not a statistical one. By that test, B scored higher only on the continuation task, and cost more on two tasks.

## Where memory made the difference

The "yesterday" session settled six decisions with the user: where the NO_COLOR check goes, which helper to use, where the tests go and how they fake a terminal, the changelog entry, and two files not to touch. It then stopped half-way. The next day's prompt was only *"Continue yesterday's work on NO_COLOR support and finish it."*

- **Arm A, no memory:** the code was correct, but none of the runs followed the agreed test location. In 2 of 3 runs the tests patched `isatty` instead of using a tty stream, and one run edited a file it had been asked to leave alone.
- **Arm B, with mind-palace:** all three runs followed every decision. The memory also held one wrong path, and all three runs checked it against the code and corrected it.

## Honest caveats

- One project, three repetitions per arm, short headless sessions (3–13 turns). Long interactive sessions may behave differently.
- The judge could partly tell the arms apart, because some B answers mention the memory file. It was told to ignore those mentions.
- The per-session overhead comes from the memory text and the plugin listing in the context. Keeping the memory short keeps it small.
