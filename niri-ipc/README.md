# niri-ipc

Upstream-named types and helpers for ciri's
[Niri](https://github.com/niri-wm/niri)-compatible IPC data model. ciri exposes
the socket through `CIRI_SOCKET`; the crate name remains unchanged to minimize
the downstream source delta.

## Backwards compatibility

This crate follows the Niri version used by ciri.
It is **not** API-stable in terms of the Rust semver.
In particular, expect new struct fields and enum variants to be added in patch version bumps.

Use an exact version requirement to avoid breaking changes:

```toml
[dependencies]
niri-ipc = "=26.4.0"
```
