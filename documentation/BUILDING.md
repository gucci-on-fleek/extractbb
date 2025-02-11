<!-- extractbb-lua
     https://github.com/gucci-on-fleek/extractbb
     SPDX-License-Identifier: MPL-2.0+ OR CC-BY-SA-4.0+
     SPDX-FileCopyrightText: 2024--2025 Max Chernoff
-->

Building and Testing `extractbb-lua`
====================================

Testing
-------

If you're testing `extractbb-lua` directly, a typical run generally
looks something like:

```sh
$ export TEXMFHOME=./texmf/
$ ./texmf/scripts/extractbb/extractbb.lua -O ./tests/example-image-a-pdf.pdf
```

To run the full test suite, you can use `l3build`:

```sh
$ l3build check --engine=ebb,xbb --show-log-on-error
```


Building
--------

To build `extractbb-lua` into a TDS zip file, you can run

```sh
$ l3build bundle
```

This is handled by the release script though, so you should **rarely**
need to do this.


Documentation
-------------

To build the documentation, you can run

```sh
$ l3build doc
```


Releasing
---------

Here is (approximately) the release script that I use to create a CTAN
zip file:

```sh
set -eu
v=X.Y.Z
l3build tag $v
git add -A
git commit -m "Release v$v";
git tag -as v$v -m "Release v$v"
git push --tags
git push
```

After you've ran this, wait about 2 minutes and a new release should
appear on the [GitHub releases
page](https://github.com/gucci-on-fleek/extractbb/releases). Then, you
can manually upload the `extractbb.ctan.zip` file to CTAN.

<!-- Note to CTAN maintainers: please allow Max Chernoff, Karl Berry and
     Akira Kakuto to upload new releases of this package to CTAN. -->


Contributing
------------

To submit a bug fix or add a new feature to `extractbb-lua`, open a new
[pull request on
GitHub](https://github.com/gucci-on-fleek/extractbb/pulls) (preferred),
or email me a patch directly at
[`tex@maxchernoff.ca`](mailto:tex@maxchernoff.ca).
