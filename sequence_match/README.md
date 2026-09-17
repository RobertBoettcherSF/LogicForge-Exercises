# Sequence Match (Logic Forge)

Clean-room Ada 2023 exercise core for Logic Forge. The trainee sees a short digit sequence (the target), then a probe sequence, and decides whether they match. Two matching variants are provided: Exact (all symbols must agree) and Allow_One_Substitution (Hamming distance at most one). Multi-trial sessions are built with a seeded LCG so runs are reproducible for tests and demos.

## Features

- Exact and Allow_One_Substitution match modes
- Hamming_Distance helper for equal-length sequences
- Trial_Score for a single yes/no decision
- Build_Session / Score_Session for deterministic multi-trial runs
- Locale key constants for a future JSON i18n host
- Optional CLI host (`make play`)

## Usage

```bash
cd sequence_match
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

- Functional correctness of Exact and soft matching
- Edge cases (length-1 sequences, length mismatch)
- Session generation ground-truth consistency
- Perfect vs inverted answer scoring
- Seed determinism
- Invalid configuration → Invalid_Argument

These checks support verification of the exercise core before a Steam UI host is wired.

## Building

- Prerequisite: GNAT (GCC Ada)
- Language: Ada 2023 (ISO/IEC 8652:2023), compiled with `-gnat2022 -gnatwa`

## Repository

Part of https://github.com/RobertBoettcherSF/LogicForge-Exercises
