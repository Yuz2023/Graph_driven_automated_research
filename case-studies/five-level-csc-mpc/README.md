# Case study: a five-level current-source inverter, from paper topology to grid-quality operation in one working day

*ELITE Grid Research Lab — all numbers transcribed from archived,
independently audited experiment artifacts.*

## Objective

The lab's graph-theory research programme derives a **new five-level
current-source inverter topology** on paper. The objective was to take it from a paper wiring diagram to a running,
closed-loop converter meeting grid power-quality limits, with every step
machine-verified.

## Process and results

1. **Operating-state analysis, exhaustive.** All **343** admissible
   switch-state combinations enumerated (never sampled) → **307** produce
   five current levels → **19 distinct output space vectors**, zero vector
   included.
2. **Current-sharing law.** The natural assumption that the DC current divides equally between
   parallel rails is incorrect for this topology. Analyzing which components are actually connected together in
   each switching state gave the correct sharing rule; prediction then
   matched simulation to 3×10⁻⁴ A.
3. **Closed-loop control on switched physics.** Predictive switching
   control (each cycle, simulate one step ahead for every candidate state,
   pick the best — no modulator): bootstrap from zero stored energy, both
   independent DC-link currents driven to the five-level operating point,
   rail balance held within ~0.7 A.
4. **Controller development in five reviewed revisions.** All
   intermediate results, including failures, remain on the record:

| Rev | Change | THD, before → after (measured) |
|---|---|---|
| v1 | initial modulation | 20.5% → **33.0–33.3%** (regression, recorded) |
| v2 | modulator logic repaired | 121.8–126.3% → 16.6–18.0% |
| v3 | rail balancing added | 36.8–36.9% → 5.0–5.4% |
| v4 | exploratory branch | 26.0–26.4% → 23.8–24.8% (reverted) |
| **v5** | current-sharing rule + LC grid interface | **42.0–42.2% → 2.09–2.28%** |

Final grid-current THD **2.09–2.28%** meets the IEEE 1547 limit (5%) with
the LC grid filter modeled explicitly.

## Verification

- First review: all executables re-run; all 12 acceptance checks
  independently recomputed and confirmed.
- Second review: five findings were raised across this research line and
  all five were confirmed, each subsequently converted into a permanent
  automated check. One finding — a THD normalization error — led to the
  retraction of an earlier compliance claim. During development, the converter degraded from five output levels to
  three while all other checks continued to pass; this was identified once
  by a human reviewer and is now an automatic level-occupancy check.

## Figures

| | |
|---|---|
| `figures/rev1_waveforms.png` | Revision 1 (recorded regression) |
| `figures/rev3_waveforms.png` | Revision 3 — rail balancing, THD 5.0–5.4% |
| `figures/rev5_waveforms_final.png` | Revision 5 — five-level PWM into a real LC grid filter, THD 2.09–2.28% |
| `figures/closedloop_bootstrap.png` | Closed-loop start-up from zero stored energy |
| `figures/current_vector_diagram.png` | The measured 19-vector current space-vector diagram, zero vector included |
