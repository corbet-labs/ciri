# Upstream synchronization

## Provenance

- Upstream repository: `https://github.com/niri-wm/niri.git`
- Fork base: `dd75865f547f0eac0e9b6c4d86d2cd00c0744252`
- Base date: 2026-08-21
- Local preparation date: 2026-08-29

The local `upstream` remote fetches Niri directly. Its push URL is disabled;
the eventual ciri repository is the only valid publication target.

## Downstream ledger

| Change | Source | Removal rule |
|---|---|---|
| Allow software EGL as a last-resort renderer and disable incompatible DMA-BUF and DRM-leasing paths | [Niri PR #3959](https://github.com/niri-wm/niri/pull/3959), commit `5aa78c08bc866af772451d276f2317ffb3ce078c` | Drop when upstream contains an equivalent accepted implementation |
| Expose the ciri command, configuration, socket, service, session, package, and documentation identity | ciri-owned product boundary | Permanent; keep limited to public and runtime-facing surfaces |

Internal `niri_*` Rust crates, types, modules, shader identifiers, and tracing
spans stay aligned with upstream unless a public ciri interface requires a
different name. ciri does not carry a private vertical-layout engine.

## Sync procedure

1. Fetch `upstream` and inspect Niri's changes since the recorded base.
2. Rebase the downstream commits onto `upstream/main` without squashing the
   software-rendering patch into the identity commit.
3. If upstream has merged an equivalent software-rendering implementation,
   drop the downstream patch instead of resolving it into a duplicate.
4. Update the fork base and patch ledger in this file.
5. Run formatting, Rust checks, tests, real-binary config validation, and the
   Nix flake checks on the designated build system before publication.

Do not validate a sync by activating ciri as the seated compositor. Runtime
canaries are a separate, explicit step after build and configuration gates pass.
