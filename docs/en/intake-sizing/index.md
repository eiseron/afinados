---
title: Intake sizing
description: What the intake-sizing tool does, the key concepts, and how to use it.
---

# Intake sizing

This tool estimates the **ideal carburetor venturi or throttle body size** for an engine and shows how the commercial sizes fit your specific RPM band. It plots throat diameter against engine speed and color-codes each commercial diameter according to the gas velocity it would deliver at the engine's typical operating RPM. Works for carbureted and EFI setups — the **Induction** field in advanced tells the model which one you're sizing.

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

- **green**: ideal — velocity sits comfortably inside the healthy band with margin before going anemic or restrictive;
- **cyan** (carburetor only): *acceptable* — gas velocity is just above the anemic floor and below ~60 m/s, the classical lower bound for solid carburetor signal. The engine runs fine there; throttle response and atomization are softer than in the green band. Injection has no cyan zone: the injector handles atomization, so low intake velocity isn't a fuel concern there;
- **light blue**: low velocity (carburetor too big for that RPM, fuel won't atomize well);
- **yellow**: restrictive (carburetor too small for that RPM, becomes a flow bottleneck).

The line is **thicker** through the RPMs where the venturi is ideal and **thinner** elsewhere.

### Engine's working regime

The same colors appear in two tones. The vivid ones (bright green, light blue, yellow) cover the RPM band where the engine actually works — its typical operating range. The dark variants (dark green, dark blue, dark yellow) cover RPMs outside that band, so you can still see the trend without giving it the same weight.

The RPM band depends on the **engine type** *and* the **application**. A Harley cruiser and a Yamaha R1 are both motorcycles, but a cruiser works around 2.5k–5.5k while a sport bike pulls 7k–14k. The Application field narrows the band:

- Motorcycle — urban (CG, daily commute), cruiser (Harley, highway torque), sporty (R1 on the road), track (closed circuit), off-road, hard enduro, motocross, rally (Dakar / adventure), drag, work (cargo / delivery)
- Car — urban (city), highway (freeway cruise), sporty, track, drag, off-road (4x4), rally, work (utility / cargo)
- Kart — race, off-road (kart cross), leisure
- Jetski — race, leisure
- Outboard — fishing, sporty, work
- Chainsaw — work, light
- Moped — commute, sporty
- Stationary — synchronous (single canonical band: 2.9k–3.7k rpm)

### The slider

A slider for **maximum volumetric efficiency** lives in the advanced section. It is the peak VE the engine reaches under load (typical street: ~85–95%; mildly tuned: ~95–105%; race with tuned intake/exhaust: ~105–115%). The chart evaluates each commercial venturi's gas velocity at this peak VE. Raising the slider increases the velocity every carburetor sees at every RPM, shifting the color picture toward restrictive (yellow) and away from anemic (blue).

## How to use

1. Pick the **engine type** (motorcycle, car, etc.). This sets the broad RPM context used to color-code the chart.
2. Pick the **application**: how the engine will actually be used (urban, cruiser, motocross, drag, …). The options are application-focused, not vehicle-style, and most are shared across motorcycle and car (urban, sporty, track, off-road, rally, drag, work). A few are vehicle-specific: *cruiser*, *hard enduro* and *motocross* on motorcycle; *highway* on car (a cruiser is a "rodovia" bike, so PT shows the same label for both). Disabled when the type has a single canonical application (e.g. stationary → synchronous).
3. Pick the **induction**: *Carburetor* (default) or *Injection*. Carburetors need gas velocity to atomize fuel through the venturi, so the healthy band has a meaningful floor (~target − 30 m/s). Injection (TBI, MPFI, ITBs) injects fuel after the throttle body, so atomization is independent of throat velocity and the floor drops (~target − 40 m/s). Restriction ceiling stays the same — the physical flow limit doesn't change.
4. Enter **displacement (cm³)**, **number of cylinders**, and **number of carburetors / throttle bodies**.
5. Read the chart: look for the sizes whose lines run **vivid green and thick** through your typical RPM. Those are the throats that breathe well at your engine's working speed.
6. Open **Advanced** to tune:
   - **Application profile**: stock, sport or competition K factor for that engine type.
   - **Barrels per carburetor**: 1 for typical motorcycles, 2 for Weber DCOE/IDF and similar.
   - **Intake manifold**: *Dedicated* (DCOE pair, CB400 four, IDA in a V8) — each carburetor feeds its own subset of cylinders. *Shared* (single Weber feeding 4 cylinders, Quadrijet, single Holley) — all carburetors feed a common plenum; more carburetors reduce per-carburetor peak velocity linearly.
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
