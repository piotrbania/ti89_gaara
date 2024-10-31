# TI-89 Gaara Virus
TI89 Titanium Resident EPO Calculator Virus, world's first virus for calculators (POC from 2007)

This project contains the source code for `ti89_gaara.asm`, a memory-resident virus designed for the TI-89 calculator. Written in Motorola 68K assembly, this proof-of-concept demonstrates techniques such as entry point obscuring and residency through ROM call table manipulation.

## Features

- **Memory Residency**: Remains active in memory, infecting other programs.
- **Entry Point Obscuring**: Alters the host's entry point to execute the virus discreetly.
- **Single Infection Check**: Prevents multiple infections of the same host.
- **Payload Activation**: Displays "t89.Gaara" on the screen under specific conditions.

## Disclaimer

This code is for educational purposes only. The author is not responsible for any misuse. Redistribution or modification without permission is prohibited.
