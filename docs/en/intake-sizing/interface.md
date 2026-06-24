---
title: Using the interface
description: A guided tour of the intake-sizing tool's interface.
---

# Using the interface

## The chart

The chart fills the main area. The horizontal axis is engine speed (RPM); the vertical axis is venturi diameter (mm). Each horizontal line is a commercial size: 10 mm, 12 mm, 14 mm, …, 60 mm.

Along each line, the **color changes by RPM**:

- **vivid green**: ideal at that RPM, inside the engine's working band;
- **dark green**: ideal velocity but the engine doesn't usually run there;
- **light blue / dark blue**: low gas velocity at that RPM (carb too big);
- **yellow / dark yellow**: restrictive at that RPM (carb too small).

The line is **thicker** through the ideal RPMs and **thinner** through the rest, so the eye picks up the green segments first.

A **legend** below the chart pairs each color with its meaning, and shows the vivid-versus-dark contrast next to the "working regime" label.

If the parameters are invalid (e.g. displacement set to 0), the chart is replaced by a short message. Fix the value to bring it back.

## The form

The form sits next to the chart (left sidebar on a wide screen, below on a phone) and is split into two sections.

### Basic

- **Engine type**: motorcycle, car, power tool, stationary or moped. Sets the RPM band the chart uses to color-code lines.
- **Displacement (cm³)**: engine total displacement.
- **Number of cylinders**.
- **Number of carburetors**: total carburetor bodies. For a 4-cylinder with a single Weber, this is 1.

### Advanced (collapsed by default)

Open the **Advanced** section to fine-tune:

- **Application profile** (K factor): stock, sport or competition variant for the chosen engine type. Higher K factors place the ideal venturi lower in the diameter range.
- **Barrels per carburetor**: 1 (most carburetors), 2 (DCOE, IDF, 2E).
- **Firing interval (crank degrees)**: only shown when cylinders share a carburetor — defines how RPM-spaced the firing pulses are. Defaults to 180° (4-cylinder even firing). Use 360° for a classic British twin, 90° for a V8, etc.
- **Boost pressure (bar)**: for blow-through turbo. 0 for naturally aspirated.
- **Maximum volumetric efficiency**: slider from 50% to 115%. Lowering it shrinks the diameter spread the chart considers; raising it pushes the upper edge higher (more breathing).

## Top bar

The brand ("Afinados") links back to the tools hub. The theme toggle switches between light and dark; the choice is saved.
