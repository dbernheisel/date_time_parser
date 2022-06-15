# Contributing

Do not submit PRs with compiled nimble parsec artifacts. The maintainer
will generate these accordingly before a release.

To run tests:
```shell
$ # This will run tests, regenerate EXAMPLES.livemd,
$ # and run Credo in strict mode.
$ mix tests
```

To build a release:
```shell
$ # bin/release {old_version} {new_version}
$ bin/release 1.1.3 1.1.4
```

Please review and agree to the [code of conduct](./CODE_OF_CONDUCT.md) before
contributing.
