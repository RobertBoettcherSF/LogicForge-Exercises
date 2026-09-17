# LogicForge-Exercises

Plain Ada 2023 exercise cores for Logic Forge (clean-room designs). Each subdirectory is a standalone package: `make test` builds and runs `tests.adb` under `-gnatwa -gnat2022`.

## Ready to try

| Exercise | Path | Status |
|----------|------|--------|
| Sequence Match | [`sequence_match/`](sequence_match/) | Full session API + CLI — **try this first** |
| Number Grid | [`number_grid/`](number_grid/) | Ready to try — session API + CLI |
| Path Plan | [`path_plan/`](path_plan/) | Ready to try — session API + CLI |
| Timed Choice RT | [`timed_choice_rt/`](timed_choice_rt/) | Ready to try — session API + CLI |
| Recall Span | [`recall_span/`](recall_span/) | Ready to try — session API + CLI |
| Rule Infer | [`rule_infer/`](rule_infer/) | Ready to try — session API + CLI |

### Quick start (any exercise)

```bash
git clone https://github.com/RobertBoettcherSF/LogicForge-Exercises.git
cd LogicForge-Exercises/<exercise>
make test    # 42 assertions, expect 0 failed / 0 warnings
make play    # optional interactive CLI
```

Locale string IDs (`*.instruction`, etc.) are ready for a JSON i18n host. Steamworks / Deck / i18n shell are separate epics.

## License

Educational / MIT-style use under RobertBoettcherSF.
