---
title: Fuel-passage area model
description: What the fuel-passage area tool calculates, what it does not, the known approximations, and the sources.
---

# The model

The fuel-passage area tool computes **geometric area**, not flow rate. It is a comparative estimate to support tuning decisions, not validated jetting advice. Tune at your own risk.

## What is calculated

The free fuel-passage area (mm²) across throttle, from:

- the **needle profile** in the needle jet bore (the annular area between needle and bore);
- the **main jet**, modeled as a restriction **in series** with the annular passage. The effective area tends toward the main jet but never reaches a hard ceiling.
- the **pilot jet**, modeled as a constant **floor** present across the whole curve;
- the **venturi**, which sets the needle stroke and therefore how far the curve goes. It does not change the shape of the shared section.

The curve starts at idle, with the needle anchored at the start of its taper, and rises with throttle.

## What is NOT calculated

- **Flow rate (vazão).** Turning area into flow needs the discharge coefficient, fuel density and the pressure drop, which are out of scope here.
- Transient and dynamic effects, the air-side cutaway of the slide, and temperature.

## Known approximations

- **Pilot jet** area is taken proportional to the jet number; the calibration constant is pending bench data.
- **Main jet** is approximated by its nominal diameter.
- **Venturi** is approximated by the needle stroke.
- Other carburetor brands (e.g. Keihin) are modeled from their own catalog data; cross-brand equivalence is approximate.

## Sources

- Catalog data (Mikuni needles, needle jets, jets) from [jetsrus.com](https://www.jetsrus.com/).
