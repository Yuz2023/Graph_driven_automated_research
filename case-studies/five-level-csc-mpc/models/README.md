# Simulink / Simscape model

`g24_5lcsc_fcsmpc.slx` — the five-level current-source-inverter closed-loop
**FCS-MPC**, realized as a Simscape Electrical model: a 3×3 ideal-switch matrix,
three star-connected DC-link rail inductors, the three-phase line-to-line grid
with AC-link capacitors, and the predictive controller as a single MATLAB
Function block (each step: predict one sample ahead for all 27 admissible switch
states and pick the minimum-cost one — no modulator).

## Provenance and regeneration

The model is generated, not hand-drawn. `build_5lcsc_mpc_slx.m` builds it
block-by-block, simulates it, and saves the `.slx`. It is a faithful
save-variant of the verified experiment script (the fixed-weight baseline of the
same closed-loop FCS-MPC used in the case study). To regenerate the model from
scratch, run `build_5lcsc_mpc_slx` in MATLAB.

## Requirements

MATLAB **R2026a** with **Simscape** and **Simscape Electrical**. The `.slx` is
saved in R2026a format and will not open in earlier releases.

## What this model shows — and what it does not

Loaded from disk and simulated standalone, it reproduces the recorded operating
point: DC-link rail tracking within **6.1%** of target, **all five** current
levels present, and rail balance **≈ 0.72 A** — the four acceptance gates
(rail-tracking, five-level occupancy, zero-state usage, AC-current tracking) all
pass.

The per-phase THD printed by the run (~37%) is the **switch-side current before
the output LC filter**. It is a *different quantity* from the grid-current THD
(**2.09–2.28%**) reported in the case study, which is measured **after** the LC
grid filter on a separate run. The two numbers are not comparable and must not
be conflated.
