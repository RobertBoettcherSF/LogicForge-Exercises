# Timed Choice RT (Logic Forge)

Clean-room Ada 2023 exercise core for Logic Forge. The host supplies `latency_ms` for each multiple-choice trial. Scoring awards 2 for correct+fast, 1 for correct+slow, and 0 for wrong. Sessions generate correct options with a seeded LCG.

## Features

- Is_Correct / Score_Band / Trial_Score
- Configurable Fast_Limit per session
- Build_Session / Score_Session for deterministic multi-trial runs
- Locale key constants for a future JSON i18n host
- Optional CLI host (`make play`)

## Usage

```bash
cd timed_choice_rt
make
make test
make play   # optional interactive run
```

Expected `make test` ending line:

```text
===  NN passed,  0 failed ===
```

## Testing

`tests.adb` covers bands, Fast_Ms boundaries, perfect/wrong/slow sessions, seed determinism, custom Fast_Limit, and Invalid_Argument.

## Building

- Prerequisite: GNAT (GCC Ada)
- Language: Ada 2023 (ISO/IEC 8652:2023), compiled with `-gnat2022 -gnatwa`

## Repository

Part of https://github.com/RobertBoettcherSF/LogicForge-Exercises
