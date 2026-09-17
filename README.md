# LogicForge-Exercises

Plain Ada 2022 CLI exercise cores for Logic Forge (clean-room designs). Each subdirectory is a standalone package.

## Quick start (repo root)

```bash
make test                 # defaults to sequence_match
make play
make test EXERCISE=novelty_check
make list
```

## Ready to try (18 cores)

| Exercise | Path |
|----------|------|
| Sequence Match | `sequence_match/` |
| Number Grid | `number_grid/` |
| Path Plan | `path_plan/` |
| Timed Choice RT | `timed_choice_rt/` |
| Recall Span | `recall_span/` |
| Rule Infer | `rule_infer/` |
| Novelty Check | `novelty_check/` |
| Visual Search | `visual_search/` |
| Go / NoGo | `go_nogo/` |
| Word Unscramble | `word_unscramble/` |
| Number Series | `number_series/` |
| Spatial Memory | `spatial_memory/` |
| Compare Items | `compare_items/` |
| Compass Orient | `compass_orient/` |
| Conflict Label | `conflict_label/` |
| Symbol Code | `symbol_code/` |
| Percent Estimate | `percent_estimate/` |
| Category Decide | `category_decide/` |

Steam GUI is a separate epic (these packages stay the headless engine).
