---
title: Fuel-passage area
description: What the fuel-passage area tool does, the key concepts, and how to use it.
---

# Fuel-passage area

This tool estimates the **fuel-passage area** of a carburetor, the cross-section available for fuel to pass, across throttle position. A larger area means more fuel can pass; comparing setups shows how a change (needle, clip, jets, venturi) reshapes the curve.

See [Using the interface](interface.md) for a full tour of the controls, and [The model](model.md) for what is calculated and the known approximations.

## Key concepts

### Setup (acerto)

A setup is the combination of catalog parts and jet sizes for one carburetor: needle, clip position, shim, needle jet, main jet, pilot jet, and venturi.

### The curve

The tool plots the free fuel-passage area (mm²) against an X axis you can switch:

- **Throttle (%):** slide opening, 0 to 100% (the rider's input).
- **Needle travel (mm):** needle displacement from idle. All setups start aligned at 0, so only the venturi sets the width.

Each axis shows its unit at its end, and the grid lines give the mm² scale.

### Comparing setups

Save setups and overlay them to compare. With two setups, the signed difference between the curves is highlighted: green where the current setup has more area, red where it has less.

## How to use

1. Pick a needle and a needle jet from the catalog.
2. Set the main and pilot jets, the clip, the shim, and the venturi.
3. Read the curve, switching the X axis between throttle and needle travel as needed.
4. **Save** the setup to keep it. Each saved setup gets its own URL (`/carburetion/setups/:id`), so you can bookmark it.
5. Mark setups to **compare** and overlay their curves.
