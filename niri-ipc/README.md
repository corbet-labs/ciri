# niri-ipc

Upstream-named types and helpers for Ciri's
[Niri](https://github.com/niri-wm/niri)-compatible IPC data model. Ciri exposes
the socket through `CIRI_SOCKET`; the crate name remains unchanged to minimize
the downstream source delta.

## Backwards compatibility

This crate follows the Niri version used by Ciri.
It is **not** API-stable in terms of the Rust semver.
In particular, expect new struct fields and enum variants to be added in patch version bumps.

Use an exact version requirement to avoid breaking changes:

```toml
[dependencies]
niri-ipc = "=26.4.0"
```
