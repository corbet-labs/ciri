<!-- SPDX-License-Identifier: Apache-2.0 -->

# Licensing policy

`ciri` is a close downstream of GPL-3.0-or-later `niri`. This policy adds
Apache-2.0 for original downstream work without attempting to relicense the
niri-derived compositor.

## Inherited and pre-existing files

Code and documentation inherited from niri or another third party retain their
existing license, copyright notices, provenance, and authorship. Existing files
continue under the license identified by their SPDX header or, when they have
no header, by their recorded upstream provenance and applicable license file.
Never replace a third-party notice merely because the file is modified
downstream.

The compositor and its existing crates remain GPL-3.0-or-later. Their Cargo
package metadata therefore continues to report `GPL-3.0-or-later`.

## Original downstream work

New standalone files independently authored for `ciri` default to the Apache
License, Version 2.0 and should carry:

```text
SPDX-License-Identifier: Apache-2.0
```

The following current downstream files are Apache-2.0:

- `LICENSING.md`
- `UPSTREAM.md`

An Apache-licensed file may be incorporated into the GPL-3.0-or-later
compositor because Apache-2.0 is GPLv3-compatible. That compatibility does not
permit the combined compositor to be redistributed under Apache-2.0 alone.

## Contributions to existing files

By intentionally submitting a contribution to this repository, the
contributor licenses any independently copyrightable original material in the
contribution under Apache-2.0. When the contribution modifies an existing GPL
file, the contributor dual-licenses that material as
`Apache-2.0 OR GPL-3.0-or-later`. This keeps the combined file and compositor
distributable under GPL, so the file's existing GPL declaration stays
unchanged.

This is a license grant, not a transfer of copyright. A submission explicitly
marked `Not a Contribution` is excluded.

## Distribution

Every distribution of the assembled ciri compositor remains subject to
GPL-3.0-or-later and must include [LICENSE](LICENSE). Apache-licensed downstream
files retain their Apache-2.0 license and require
[LICENSE-APACHE](LICENSE-APACHE) as well. Relicensing the complete compositor
would require permission from all relevant niri copyright holders; this policy
does not claim or provide that permission.
