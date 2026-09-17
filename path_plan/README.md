# Path Plan (Logic Forge)

Clean-room Ada 2023 exercise core for Logic Forge. The trainee proposes a 4-neighbour path on a small Open/Wall grid. Scoring rewards a valid path and a bonus when the path reaches the published start→goal. Multi-trial sessions use a seeded LCG so maps are reproducible.

## Features

- Is_Valid_Path (bounds, walls, adjacency)
- Reaches_Goal and Path_Score (0 / 1 / 2)
- Build_Session / Score_Session for deterministic multi-trial runs
- Locale key constants for a future JSON i18n host
- Optional CLI host (`make play`)

## Usage

```bash
cd path_plan
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

- Functional correctness of path validation and scoring
- Edge cases (single-cell map, jumps, walls)
- Session generation ground-truth consistency
- Perfect vs short answer scoring
- Seed determinism
- Invalid configuration → Invalid_Argument

## Building

- Prerequisite: GNAT (GCC Ada)
- Language: Ada 2023 (ISO/IEC 8652:2023), compiled with `-gnat2022 -gnatwa`

## Repository

Part of https://github.com/RobertBoettcherSF/LogicForge-Exercises
