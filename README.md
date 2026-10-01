# template-zig

Minimal Zig template, hooks via [prek](https://prek.j178.dev).

```
src/root.zig    library module
src/main.zig    executable
tools/          build helpers (coverage check)
```

```sh
prek install                         # install pre-commit + pre-push hooks
zig build run
zig build test
zig build -Doptimize=ReleaseFast     # full LTO, stripped
zig build coverage                   # kcov → zig-out/coverage/index.html, fails below 80%
prek run -a                          # pre-commit hooks
prek run -a --hook-stage pre-push    # pre-push hooks
```

- pre-commit: `zig fmt`, `zig build`
- pre-push: `zig build test coverage` (tests + coverage gate)

Opinionated defaults: native CPU target, release builds use full LTO and are stripped.

## Coverage

[kcov](https://github.com/SimonKagstrom/kcov) (`nix shell nixpkgs#kcov`, `apt install kcov`) runs on pre-push and in CI. Coverage of `src/` (library tests) fails below 80% lines; override with `zig build coverage -Dcoverage-min=90`. The check is `tools/coverage_check.zig`, reading kcov's `coverage.json`.
