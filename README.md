# LogicForge-Exercises

Plain Ada 2022 CLI exercise cores for Logic Forge (clean-room designs). Each subdirectory is a standalone package.

## Quick start (repo root)

```bash
make test                 # defaults to sequence_match
make play
make test EXERCISE=novelty_check
make list
```

## Ready to try

| Exercise | Path | Status |
|----------|------|--------|
| Sequence Match | `sequence_match/` | Ready |
| Number Grid | `number_grid/` | Ready |
| Path Plan | `path_plan/` | Ready |
| Timed Choice RT | `timed_choice_rt/` | Ready |
| Recall Span | `recall_span/` | Ready |
| Rule Infer | `rule_infer/` | Ready |
| Novelty Check | `novelty_check/` | Ready |
| Visual Search | `visual_search/` | Ready |
| Go / NoGo | `go_nogo/` | Ready |
| Word Unscramble | `word_unscramble/` | Ready |
| Number Series | `number_series/` | Ready |
| Spatial Memory | `spatial_memory/` | Ready |

Locale string IDs are ready for a future JSON i18n host. Steam GUI is a separate epic (headless cores stay the engine).
