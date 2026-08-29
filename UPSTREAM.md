<!-- SPDX-License-Identifier: Apache-2.0 -->

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
| Allow software EGL as a last-resort renderer, disable incompatible DMA-BUF and DRM-leasing paths, and keep its GPU-manager identity on the primary render node | [Niri PR #3959](https://github.com/niri-wm/niri/pull/3959), cherry-pick `e395a274`; VM-discovered node correction `3a27dceb` | Drop both commits when upstream contains an equivalent accepted implementation |
| Expose the ciri command, configuration, service, session, package, and documentation identity while retaining Niri-compatible IPC discovery | ciri-owned product boundary | Permanent; keep the IPC environment variable and socket filename aligned with Niri |

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
