# Recall Span (Logic Forge)

Clean-room Ada 2023 exercise core for Logic Forge. A digit sequence is presented; the trainee recalls it. Scoring uses Exact_Match for full credit or Prefix_Span for partial credit. Sessions increase length trial by trial with a seeded LCG.

## Features

- Exact_Match / Prefix_Span / Trial_Score
- Build_Session / Score_Session with increasing lengths
- Locale key constants for a future JSON i18n host
- Optional CLI host (`make play`)

## Usage

```bash
cd recall_span
make
make test
make play   # optional interactive run
```

Expected `make test` ending line:

```text
===  NN passed,  0 failed ===
```

## Testing

`tests.adb` covers exact/prefix scoring, empty recall, increasing session lengths, perfect vs partial answers, seed determinism, and Invalid_Argument.

## Building

- Prerequisite: GNAT (GCC Ada)
- Language: Ada 2023 (ISO/IEC 8652:2023), compiled with `-gnat2022 -gnatwa`

## Repository

Part of https://github.com/RobertBoettcherSF/LogicForge-Exercises
