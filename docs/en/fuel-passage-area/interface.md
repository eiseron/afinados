---
title: Using the interface
description: A guided tour of the fuel-passage area tool's interface.
---

# Using the interface

## Top bar

The brand ("Afinados") links back to the tools hub. The theme toggle switches between light and dark, and the choice is saved. Without a choice, the theme follows your operating system.

## The chart

The curve fills the top of the screen. On a phone it stays pinned while the controls scroll below; on a wide screen the controls move to a left sidebar.

The **View by** button switches the X axis between **throttle (%)** and **needle travel (mm)**. It shows the axis you switch to, not the current one. Each axis shows its unit at the end (%, mm, mm²), and the grid lines give the scale.

If the setup is invalid (for example a jet set to 0), the chart is replaced by a short message. Fix the value to bring the curve back.

## The controls

The needle and the needle jet are picked from the catalog (dropdowns). The main jet, pilot jet, shim and venturi take numbers. The clip is a dropdown bounded by the needle's clip count, so an invalid position cannot be chosen.

**Save setup** stores the current setup.

## Saved setups

The **Saved setups** panel sits above the form. It is collapsible and stays visible even when empty, with a count.

- Each saved setup shows its parts (jets, needle, clip).
- **Compare:** tick a setup to overlay its curve. The checkbox at the top of the list selects or clears all of them.
- **Load:** click a setup to load it. The address bar changes to the setup's own URL (`/carburetion/setups/:id`), which you can bookmark.
- **Delete:** the × removes a setup, after a confirmation.

## Notifications

Saving or deleting shows a brief toast in the bottom-right corner (full width on a phone). Close it with the × or let it dismiss.

## Sharing

A saved setup's URL only resolves in the browser that created it, since setups are private to your session. Opening an unknown setup URL redirects you back to the tool with a "not found" notice.
