<!-- extractbb-lua
     https://github.com/gucci-on-fleek/extractbb
     SPDX-License-Identifier: MPL-2.0+ OR CC-BY-SA-4.0+
     SPDX-FileCopyrightText: 2024 Max Chernoff
-->

`extractbb-lua`
===============

A reimplementation of
[`extractbb`](https://texdoc.org/serve/extractbb/0), written in Lua.


Variants
--------

There are two variants of `extractbb-lua`:

- **`wrapper`**: A wrapper script around the original `xdvipdmfx`-based
  `extractbb` that is used to fix a security vulernability in
  `xdvipdfmx`.

- **`scratch`**: A standalone implementation of `extractbb`, written in
  Lua from scratch, with no dependencies on `xdvipdfmx`.

Currently, the script `extractbb` defaults to the `wrapper` variant, but
you can manually select any specific variant by setting the
`TEXLIVE_EXTRACTBB` environment variable to either `wrapper` or
`scratch`.


Support
-------

If you have any problems with this tool, please report it (in order of
preference):

1. By [opening a new issue on
   GitHub](https://github.com/gucci-on-fleek/extractbb/issues/new).

2. Via email to the public [`tex-live@tug.org` mailing list](https://tug.org/mailman/listinfo/tex-live).

3. By contacting the author directly at `tex@maxchernoff.ca`.


Licence
-------

`extractbb-lua` is licensed under the [_Mozilla Public License_, version
2.0](https://www.mozilla.org/en-US/MPL/2.0/) or greater. The
documentation is additionally licensed under [CC-BY-SA, version
4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) or
greater.

---
_v0.0.3 (2024-11-17)_ <!--%%version %%dashdate-->
