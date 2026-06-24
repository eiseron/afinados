---
title: Intake sizing model
description: What the intake-sizing tool calculates, the formula, the known approximations, and the sources.
---

# The model

The intake-sizing tool gives a **geometric estimate** of the venturi diameter that matches an engine's air demand. It is a comparative tool to support carburetor selection, not a validated jetting recommendation. Tune at your own risk.

## The formula

The diameter is computed from a Bernoulli-derived sizing equation:

```
D = K × √(Vt × RPM × VE / (N × 1000 × P_abs))
```

Where:

- **D** — venturi diameter (mm)
- **Vt** — total displacement (cm³)
- **RPM** — engine speed
- **VE** — volumetric efficiency (0.5 to 1.15)
- **N** — *pulse divisor*, a function of cylinder count, venturi count, barrels and firing interval (see below)
- **P_abs** — absolute pressure (1 + boost in bar)
- **K** — application-profile constant (0.50–0.88, depending on engine type)

The K factor implicitly encodes the target peak gas velocity through the venturi. Higher K values target lower velocity, which gives a smaller carb for the same engine; lower K values target higher velocity (race tuning).

## The pulse divisor

For each commercial size the chart plots an RPM window. The boundary depends on how many cylinders feed each venturi:

```
N = max(venturis, cylinders / concurrent)
concurrent = max(1, 240 / (firing_interval × venturis))
```

The `concurrent` factor handles **pulse overlap** when multiple cylinders share a carburetor. If the firing interval per venturi is shorter than the intake duration (~240° of crank rotation), pulses overlap and the effective peak demand rises.

For typical 1-carb-per-cylinder setups, `N = venturis = carbs × barrels`.

## Gas velocity for color coding

Each commercial line is colored by the **peak gas velocity** at the engine's typical RPM:

```
v = Vt × VE × RPM / (10 × N × π × D²)   (m/s)
```

Thresholds:

- **< 60 m/s**: low velocity — fuel doesn't atomize well, the carb is too big for that RPM.
- **60–130 m/s**: sufficient — healthy operating range.
- **> 130 m/s**: restrictive — the venturi becomes a flow bottleneck.

## What is NOT calculated

- **Flow rate (vazão)** as actually measured on a flow bench. The formula uses geometric and breathing assumptions, not discharge coefficients.
- Transient effects (gas inertia in the manifold, intake tract resonance).
- Fuel atomization quality, mixture distribution, or AFR.
- Carburetor body losses outside the venturi (slide cutaway, throat shape).

## Known approximations

- **Intake duration** is assumed to be ~240° of crank rotation. Real cams vary from 200° to 280°.
- **Pulse overlap** is modeled with a simple linear scaling — overlapping pulses share the carb proportionally to their duration overlap. Real engines have more complex pressure waves.
- **Firing pattern** defaults to even firing (`720° ÷ cylinders`). Uneven-firing engines (270° twins, V8 with cross-plane crank) can be approximated by setting the firing interval manually.
- **VE_min** is derived from VE_max minus 30 percentage points, a typical fall-off across the rev range. Highly tuned engines hold VE longer (smaller drop); restrictive setups drop more.

## Sources

The K factor presets and velocity targets are drawn from common carburetion literature: David Vizard, Graham Bell, Dellorto's official tuning guides. Real-world carburetor sizes used to validate the model (Honda CG 125, VW Fusca, Ford Maverick V8, Harley-Davidson Evo 1340, and several others) come from manufacturer service manuals and aftermarket racing references.
