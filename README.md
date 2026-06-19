# Afinados

Calculation tools for motorcycle preparation. The first tool estimates carburetor
geometry and plots, as a curve, how each change of needle, jet, clip or venturi
alters the fuel passage, so you tune with method instead of guesswork.

- **App:** https://app.afinados.io
- **Site:** https://afinados.io
- **Docs:** https://afinados.io/docs

## What it does

Afinados models the free fuel-passage area of a Mikuni or Keihin carburetor across
throttle position — including drop-in equivalents (NIBBI, KOSO, OKO and other
clones that share the original geometry). Build a setup from the catalog
(manufacturer, needle, needle jet, high/low jets, clip, shim and venturi), read the
resulting curve, and overlay two setups to see, with a signed difference, where one
flows more or less than the other before touching the engine.

It produces geometric estimates, not measured flow. It does not replace bench, dyno
or track testing.

## Stack

Phoenix LiveView (Elixir) and PostgreSQL. Charts are SVG rendered on the server, with
no client-side charting library.

## Development

The local environment is provisioned with Docker Compose:

```sh
docker compose up
```

The app starts on http://localhost:4000. Run project commands (Mix tasks, tests)
inside the Compose services, and run `mix precommit` before committing.

## License

[Functional Source License 1.1, ALv2 future license](LICENSE.md). Copyright Eiseron.
