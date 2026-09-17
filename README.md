# LogicForge-Exercises

Plain Ada 2023 exercise cores for Logic Forge (clean-room designs). Each subdirectory is a standalone package: `make test` builds and runs `tests.adb` under `-gnatwa -gnat2022`.

## Ready to try

| Exercise | Path | Status |
|----------|------|--------|
| Sequence Match | [`sequence_match/`](sequence_match/) | Full session API + CLI — **try this first** |
| Number Grid | [`number_grid/`](number_grid/) | Spec stub |
| Path Plan | [`path_plan/`](path_plan/) | Spec stub |
| Timed Choice RT | [`timed_choice_rt/`](timed_choice_rt/) | Spec stub |
| Recall Span | [`recall_span/`](recall_span/) | Spec stub |
| Rule Infer | [`rule_infer/`](rule_infer/) | Spec stub |

### Sequence Match (first playable)

```bash
git clone https://github.com/RobertBoettcherSF/LogicForge-Exercises.git
cd LogicForge-Exercises/sequence_match
make test    # 42 assertions, expect 0 failed
make play    # interactive y/n session (seed 42)
```

Locale string IDs (`sequence_match.instruction`, etc.) are ready for a JSON i18n host. Steamworks / Deck / i18n shell are separate epics.

## License

Educational / MIT-style use under RobertBoettcherSF.
