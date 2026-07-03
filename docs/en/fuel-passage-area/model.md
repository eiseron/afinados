---
title: Fuel-passage area model
nav_title: The model
description: What the fuel-passage area tool calculates, what it does not, the known approximations, and the sources.
---

# The model

The fuel-passage area tool computes **geometric area**, not flow rate. It is a comparative estimate to support tuning decisions, not validated jetting advice. Tune at your own risk.

## What is calculated

The free fuel-passage area (mm²) across throttle, as the **sum** of two parallel contributions:

- the **main circuit**: the annular passage between needle and needle jet **in series** with the main jet. The effective area tends toward the main jet but never reaches a hard ceiling;
- the **pilot circuit**, added in parallel as a constant contribution present across the whole curve.

The **venturi** sets the needle stroke and therefore how far the curve goes. It does not change the shape of the shared section.

The curve starts at idle — with the main circuit's contribution at the idle position summed with the pilot — and rises with throttle as the needle lifts and the annular area opens.

The catalog covers Mikuni and Keihin (FCR 28-41mm, PWK/PJ 34-39mm). Drop-in clones such as NIBBI, KOSO and OKO share the original geometry, so the same catalog applies to them.

## What is NOT calculated

- **Flow rate (vazão).** Turning area into flow needs the discharge coefficient, fuel density and the pressure drop, which are out of scope here.
- Transient and dynamic effects, the air-side cutaway of the slide, and temperature.

## Known approximations

- **Pilot jet** Keihin area is derived from its nominal diameter (jets numbered in 1/100 mm). Mikuni's is taken proportional to the jet number as a placeholder; the calibration constant is pending bench data.
- **Main jet** is approximated by its nominal diameter (modern round-head Mikuni and Keihin alike).
- **Venturi** is approximated by the needle stroke.
- Each manufacturer is modeled from its own catalog data; cross-brand numbering equivalence is approximate.

## Sources

- Catalog data (Mikuni and Keihin needles and needle jets) from [jetsrus.com](https://www.jetsrus.com/).
- Keihin FCR/PWK jet-needle geometry from the official Keihin PDFs (keihin-na.com).
