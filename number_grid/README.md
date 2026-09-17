# Number Grid (Logic Forge)

Clean-room Ada 2023 exercise core for Logic Forge. The trainee fills a small NxN numeric grid so that every row and every column meets a published target sum. Multi-trial sessions are built with a seeded LCG so puzzles are reproducible for tests and demos.

## Features

- Row_Sums_Ok / Col_Sums_Ok / Solution_Ok checks
- Compute_Row_Sum / Compute_Col_Sum helpers
- Grid_Score partial credit (one point per correct row or column)
- Build_Session / Score_Session for deterministic multi-trial runs
- Locale key constants for a future JSON i18n host
- Optional CLI host (`make play`)

## Usage

```bash
cd number_grid
make
make test
make play   # optional interactive run
```

Expected `make test` ending line:

```text
===  NN passed,  0 failed ===
```

## Testing

`tests.adb` is the main executable and the usage example. Categories covered:

- Functional correctness of sum checks and scoring
- Edge cases (1x1 grid, partial credit)
- Session generation ground-truth consistency
- Perfect vs zero-filled answer scoring
- Seed determinism
- Invalid configuration → Invalid_Argument

These checks support verification of the exercise core before a Steam UI host is wired.

## Building

- Prerequisite: GNAT (GCC Ada)
- Language: Ada 2023 (ISO/IEC 8652:2023), compiled with `-gnat2022 -gnatwa`

## Repository

Part of https://github.com/RobertBoettcherSF/LogicForge-Exercises
