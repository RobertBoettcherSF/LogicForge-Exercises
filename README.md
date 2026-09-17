# LogicForge-Exercises

Plain **Ada 2022** exercise cores for Logic Forge (clean-room designs).

## Exercises

| Folder | Status |
|--------|--------|
| `sequence_match/` | Session loop + CLI (`make play`) — tests green |
| `number_grid/` | Stub — tests green |
| `path_plan/` | Stub — tests green |
| `timed_choice_rt/` | Stub — tests green |
| `recall_span/` | Stub — tests green |
| `rule_infer/` | Stub — tests green |

## Build one exercise

```bash
cd sequence_match
make && make test
make play   # Sequence Match interactive CLI
```

Requires GNAT (Ada 2022).

## Notes

- No SPARK required for these cores (yet).
- UI / Steam host maps i18n keys (see Sequence Match) via JSON locales later.
