# Sequence Match (Logic Forge)

Plain Ada 2022 exercise core + playable session loop.

**Clean-room:** original design. Player sees a short digit sequence, then a probe; decide match / no-match under Exact or Allow-One-Substitution mode.

## Build

```bash
make && make test
make play   # interactive CLI host
```

## API

- `Is_Match` / `Trial_Score` — single-trial logic
- `Build_Session` / `Score_Session` — deterministic session (seeded LCG)
- i18n keys: `sequence_match.instruction`, `sequence_match.prompt_match`, `yes` / `no`

Host (Steam UI later) maps keys via JSON locales; CLI `play` is a temporary shell.
