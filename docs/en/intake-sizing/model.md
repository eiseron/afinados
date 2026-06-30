---
title: Intake sizing model
description: What the intake-sizing tool calculates, the formula, the known approximations, and the sources.
---

# The model

The intake-sizing tool gives a **geometric estimate** of how well each commercial venturi flows for a given engine, by computing the peak gas velocity through it. It is a comparative tool to support carburetor selection, not a validated jetting recommendation. Tune at your own risk.

## Gas velocity is the primary signal

For any commercial venturi diameter at any RPM, the peak gas velocity is:

```
v = Vt × VE × RPM / (10 × N × π × D²)   (m/s)
```

Where:

- **v** — peak gas velocity at the venturi throat (m/s)
- **Vt** — total displacement (cm³)
- **VE** — peak volumetric efficiency (0.5 to 1.15)
- **RPM** — engine speed
- **N** — *pulse divisor*, a function of cylinders, carburetors, barrels and firing interval (see below)
- **D** — venturi diameter (mm)

Two boundary effects matter:

- **Too low** → fuel atomizes poorly, mixture distribution suffers.
- **Too high** → the venturi itself restricts flow and the engine cannot breathe at the top.

Each commercial line on the chart is colored by where its velocity lands at each RPM.

## Target velocity from the application profile (K)

The **application profile** (stock, sport, competition — one constant K per option) encodes which peak velocity the build is aimed at. Substituting the classic Bernoulli-derived venturi-sizing equation into the velocity equation cancels every engine variable and leaves a clean relationship:

```
v_target = 100 × P_abs / (π × K²)   (m/s)
```

Where **P_abs** = 1 + boost (bar). So K is, in effect, a velocity-target selector:

- Stock motorcycle (K=0.70): ~65 m/s
- Sport motorcycle (K=0.72): ~61 m/s
- Race motorcycle (K=0.75): ~57 m/s
- Stock car (K=0.60): ~88 m/s
- Race car (K=0.70): ~65 m/s

The healthy band on the chart is centered on **v_target** with a fixed half-width of ±30 m/s. Changing the application profile shifts the band and re-colors the chart.

## The pulse divisor

The pulse divisor `N` converts total engine demand into the peak demand seen by one venturi:

```
N = max(venturis, cylinders / concurrent)
concurrent = max(1, 240 / (firing_interval × venturis))
```

The `concurrent` factor handles **pulse overlap** when multiple cylinders share a carburetor. If the firing interval per venturi is shorter than the intake duration (~240° of crank rotation), pulses overlap and the effective peak demand rises.

For typical 1-carburetor-per-cylinder setups, `N = venturis = carburetors × barrels`.

## What is NOT calculated

- **Flow rate (vazão)** as actually measured on a flow bench. The formula uses geometric and breathing assumptions, not discharge coefficients.
- Transient effects (gas inertia in the manifold, intake tract resonance).
- Fuel atomization quality, mixture distribution, or AFR.
- Carburetor body losses outside the venturi (slide cutaway, throat shape).

## Known approximations

- **Intake duration** is assumed to be ~240° of crank rotation. Real cams vary from 200° to 280°.
- **Pulse overlap** is modeled with a simple linear scaling — overlapping pulses share the carburetor proportionally to their duration overlap. Real engines have more complex pressure waves.
- **Firing interval** is a manual field defaulting to **180°** (even firing for a 4-cylinder). It does not derive from the cylinder count: for other cylinder counts or uneven-firing engines (270° twins, cross-plane V8), set the interval manually.
- **VE** is taken as the *peak* value (single slider input). The chart evaluates velocity at this peak; real engines see lower VE outside peak-power RPM.

## Sources

The K factor presets are drawn from common carburetion literature: David Vizard, Graham Bell, Dellorto's official tuning guides. Real-world carburetor sizes used to validate the model (Honda CG 125, VW Fusca, Ford Maverick V8, Harley-Davidson Evo 1340, and several others) come from manufacturer service manuals and aftermarket racing references.
