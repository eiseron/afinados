---
title: Intake sizing
description: What the intake-sizing tool does, the key concepts, and how to use it.
---

# Intake sizing

This tool estimates the **ideal carburetor venturi size** for an engine and shows how the commercial sizes fit your specific RPM band. It plots venturi diameter against engine speed and color-codes each commercial diameter according to the gas velocity it would deliver at the engine's typical operating RPM.

See [Using the interface](interface.md) for a tour of the controls, and [The model](model.md) for the formula and known approximations.

## How carburetor admission works

An Otto-cycle engine is a vacuum pump. Each intake stroke pulls air through the carburetor; the carburetor narrows the air path at the **venturi**, and the air speeds up there. Faster air drops the pressure (Bernoulli's principle), and the low pressure is what siphons fuel out of the jets. So venturi sizing is really about **what gas velocity** you want at the engine's working RPM.

Two things can go wrong:

- **Too small a venturi.** Air hits very high velocity, the pressure drop is large, and the venturi itself starts to **restrict flow**. The engine breathes through a straw — top end suffers.
- **Too big a venturi.** Air barely accelerates, the pressure drop is weak, and fuel is **poorly atomized**. Throttle response goes soft, the engine bogs at low and mid RPM, and the mixture stays uneven.

There is a healthy band in between (roughly **60–130 m/s** of peak gas velocity) where atomization is good and restriction is low. The whole point of the chart is to show, for each commercial venturi size and each RPM, where you sit in that band.

Air demand scales with **displacement × RPM × volumetric efficiency** and inversely with **how many cylinders share each carburetor**. That is why the "ideal" venturi for one engine is wrong for another, and why the same venturi can be ideal at one RPM and restrictive at another.

## Key concepts

### The chart

Each horizontal line on the chart is a commercial venturi size (in mm). The line's color along the X axis (RPM) tells you how that venturi performs at that engine speed:

- **green**: ideal — gas velocity sits in the healthy band (60–130 m/s);
- **light blue**: low velocity (carb too big for that RPM, fuel won't atomize well);
- **yellow**: restrictive (carb too small for that RPM, becomes a flow bottleneck).

The line is **thicker** through the RPMs where the venturi is ideal and **thinner** elsewhere.

### Engine's working regime

The same colors appear in two tones. The vivid ones (bright green, light blue, yellow) cover the RPM band where the engine actually works — its typical operating range. The dark variants (dark green, dark blue, dark yellow) cover RPMs outside that band, so you can still see the trend without giving it the same weight.

The RPM band depends on the engine type you pick:

- Motorcycle: 2.500–14.000 rpm
- Moped: 3.000–10.000 rpm
- Kart: 9.000–14.500 rpm
- Jetski: 5.000–9.000 rpm
- Outboard: 3.000–6.500 rpm
- Chainsaw: 6.000–13.000 rpm
- Stationary engine (generator, pump): 2.900–3.700 rpm
- Car: 1.500–6.500 rpm

### The slider

A slider for **maximum volumetric efficiency** lives in the advanced section. It is the peak VE the engine reaches under load (typical street: ~85–95%; mildly tuned: ~95–105%; race with tuned intake/exhaust: ~105–115%). The chart evaluates each commercial venturi's gas velocity at this peak VE. Raising the slider increases the velocity every carb sees at every RPM, shifting the color picture toward restrictive (yellow) and away from anemic (blue).

## How to use

1. Pick the **engine type** (motorcycle, car, etc.). This sets the RPM band used to color-code the chart.
2. Enter **displacement (cm³)**, **number of cylinders**, and **number of carburetors**.
3. Read the chart: look for the venturi sizes whose lines run **vivid green and thick** through your typical RPM. Those are the venturis that breathe well at your engine's working speed.
4. Open **Advanced** to tune:
   - **Application profile**: stock, sport or competition K factor for that engine type.
   - **Barrels per carburetor**: 1 for typical motorcycles, 2 for Weber DCOE/IDF, 4 for a Quadrijet/Holley 4-barrel.
   - **Intake manifold**: *Dedicated* (DCOE pair, CB400 four, IDA in a V8) — each carb feeds its own subset of cylinders. *Shared* (single Weber feeding 4 cyl, Quadrijet, single Holley) — all carbs feed a common plenum; more carbs reduce per-carb peak velocity linearly.
   - **Firing interval**: crank degrees between cylinder firings. Active only when cylinders share a carburetor. Accounts for pulse overlap when multiple cylinders feed the same venturi.
   - **Boost pressure (bar)**: for blow-through turbo setups.
   - **Maximum volumetric efficiency**: ranges from 50% (worn, very restrictive) to 115% (race with tuned intake/exhaust).

## Reading the results

A few rules of thumb when looking at the chart:

- **Pick the size that stays green across your typical RPM.** If several sizes qualify, the smaller one usually gives better throttle response, the larger one gives more peak power.
- **If no size stays fully green**, decide which trade-off you can live with. A line that's green at the top of the band and yellow at the bottom is a "top-end" choice — it makes power but feels sluggish to pull away. A line that's green at the bottom and blue at the top is a "tractable" choice — crisp off idle but it runs out of breath.
- **Yellow inside your band = too small.** That venturi chokes at the RPMs you use.
- **Blue inside your band = too big.** That venturi will atomize poorly and feel soft.
- **Dark colors are outside your working range** — useful for context, but don't pick a venturi based on them.

Tune the **Application profile** and **Maximum volumetric efficiency** to match your engine's state: stock cam and pump fuel → leave defaults; race head, big cam and tuned exhaust → raise both. The chart shifts accordingly.
