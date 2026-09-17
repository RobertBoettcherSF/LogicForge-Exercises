# Rule Infer (Logic Forge)

Clean-room Ada 2023 exercise core for Logic Forge. A hidden rule (Even, Odd, At_Least, or Multiple_Of) generates positive examples. The trainee classifies probe integers; sessions score each yes/no decision.

## Features

- Obeys / Trial_Score for Even, Odd, At_Least, Multiple_Of
- Build_Session / Score_Session with seeded examples and probes
- Locale key constants for a future JSON i18n host
- Optional CLI host (`make play`)

## Usage

```bash
cd rule_infer
make
make test
make play   # optional interactive run
```

Expected `make test` ending line:

```text
===  NN passed,  0 failed ===
```

## Testing

`tests.adb` covers rule kinds, edge values, session ground truth, perfect vs inverted answers, seed determinism, and Invalid_Argument.

## Building

- Prerequisite: GNAT (GCC Ada)
- Language: Ada 2023 (ISO/IEC 8652:2023), compiled with `-gnat2022 -gnatwa`

## Repository

Part of https://github.com/RobertBoettcherSF/LogicForge-Exercises
