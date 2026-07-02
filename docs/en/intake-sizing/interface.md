---
title: Using the interface
description: A guided tour of the intake-sizing tool's interface.
---

# Using the interface

## The chart

The chart fills the main area. The horizontal axis is engine speed (RPM); the vertical axis is venturi diameter (mm). Each horizontal line is a commercial size: 10 mm, 12 mm, 14 mm, …, 60 mm.

Along each line, the **color changes by RPM**:

- **vivid green / dark green**: ideal — velocity sits inside the healthy band with margin from both edges (dark variant = outside the working band);
- **cyan / dark cyan** (carburetor only): *acceptable* — velocity is just above anemic and below ~60 m/s, the classical lower bound for solid carburetor signal. Injection has no cyan zone since atomization is injector-driven (dark variant = outside the working band);
- **light blue / dark blue**: low gas velocity at that RPM (carburetor too big);
- **yellow / dark yellow**: restrictive at that RPM (carburetor too small).

The line is **thicker** through the ideal RPMs and **thinner** through the rest, so the eye picks up the green segments first.

A **legend** below the chart pairs each color with its meaning, and shows the vivid-versus-dark contrast next to the "working regime" label.

If the parameters are invalid (e.g. displacement set to 0), the chart is replaced by a short message. Fix the value to bring it back.

## The form

The form sits next to the chart (left sidebar on a wide screen, below on a phone) and is split into two sections.

### Basic

- **Engine type**: motorcycle, car, kart, jetski, outboard, chainsaw, stationary or moped. Sets the broad RPM context the chart uses to color-code lines.
- **Application**: how the engine will actually be used, not its body style. A Honda CG is *urban*, not "naked"; a Harley is *cruiser* (highway, torque-optimized); an R1 is *sporty* on the road and *track* on a circuit. Most options are shared across motorcycle and car; a few are vehicle-specific (cruiser, hard enduro and motocross are moto-only; highway is car-only — same concept as cruiser, different label by convention). Disabled (not hidden) when the type has a single canonical application (e.g. stationary → synchronous).
- **Induction**: carburetor or electronic injection. Adapts the velocity tolerance and the labels of related fields.
- **Displacement (cm³)**: engine total displacement.
- **Number of cylinders**.
- **Number of carburetors / throttle bodies**: total carburetor (or TBI) bodies. For a 4-cylinder with a single Weber, this is 1.

### Advanced (collapsed by default)

Open the **Advanced** section to fine-tune:

- **Application profile** (K factor): stock, sport or competition variant for the chosen engine type. Higher K factors place the ideal venturi lower in the diameter range.
- **Barrels per carburetor**: 1 (most carburetors), 2 (DCOE, IDF, 2E).
- **Firing interval**: crank degrees between cylinder firings — active only when cylinders share a carburetor. Defaults to 180° (4-cylinder even firing). Use 360° for a classic British twin, 90° for a V8, etc.
- **Boost pressure (bar)**: for blow-through turbo. 0 for naturally aspirated.
- **Maximum volumetric efficiency**: slider from 50% to 115%. Lowering it shrinks the diameter spread the chart considers; raising it pushes the upper edge higher (more breathing).

## Top bar

The brand ("Afinados") links back to the tools hub. The theme toggle switches between light and dark; the choice is saved. The language switch (PT/EN), next to the theme toggle, changes the interface language; the choice is saved.
