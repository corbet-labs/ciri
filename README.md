# Ciri

Ciri is a deliberately close fork of
[Niri](https://github.com/niri-wm/niri), the scrollable-tiling Wayland
compositor built on Smithay. It gives the downstream product its own runtime
identity and carries only the small compositor patch set that cannot yet be
consumed from upstream.

## Downstream changes

- The public command is `ciri`.
- User configuration lives at `$XDG_CONFIG_HOME/ciri/config.kdl`, with
  `/etc/ciri/config.kdl` as the system fallback and `CIRI_CONFIG` as the
  explicit override.
- IPC uses `CIRI_SOCKET` and `ciri.*.sock`; session, service, desktop, portal,
  Dinit, completion, and package names use `ciri` consistently.
- Niri's proposed software-rendering change from
  [PR #3959](https://github.com/niri-wm/niri/pull/3959) is carried as an
  isolated commit. It permits a software EGL renderer as a fallback and
  disables DMA-BUF and DRM leasing while that renderer is active.

The software-rendering patch is not a Cairo or Pixman renderer, and it does not
add a Ciri-specific layout engine. Ciri follows Niri's scrolling and layout work
upstream.

## Upstream compatibility

The configuration grammar, IPC data model, and most implementation names remain
aligned with Niri. Internal crates such as `niri-config` and `niri-ipc` retain
their upstream names to keep rebases small; this does not expose the retired
Niri runtime paths, service names, or environment variables.

Niri's [documentation](https://niri-wm.github.io/niri/) remains the reference
for compositor behavior and configuration syntax. In command and installation
examples, substitute Ciri's public command and paths listed above.

See [UPSTREAM.md](UPSTREAM.md) for the exact base, downstream patch ledger, and
sync procedure.

## Scope

This repository contains the compositor runtime only. Public Nix integration
belongs in `nixciri`; host-specific configuration, desktop shell components,
and personal workspace policy do not belong here.

## License

Ciri preserves Niri's GNU General Public License, version 3 or later, and its
upstream history and authorship. See [LICENSE](LICENSE).
