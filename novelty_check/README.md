# Novelty Check (Logic Forge)

Clean-room Ada 2022 CLI core. Symbols appear one at a time; decide whether each was already shown earlier in the session.

## Features

- Seeded session generation with controlled repeat rate
- Trial_Score and Score_Session
- Locale key constants for a future JSON i18n host

## Usage

```bash
make test
make play
```

## Building

GNAT, Ada 2022 (`-gnat2022 -gnatwa`).
