# template-zig

Minimal Zig template, hooks via [prek](https://prek.j178.dev).

```
src/root.zig    library module
src/main.zig    executable
```

```sh
prek install                         # install pre-commit + pre-push hooks
zig build run
zig build test
zig build -Doptimize=ReleaseFast     # full LTO, stripped
zig build coverage                   # kcov → zig-out/coverage/index.html
prek run -a                          # pre-commit hooks
prek run -a --hook-stage pre-push    # pre-push hooks
```

- pre-commit: `zig fmt`, `zig build`
- pre-push: `zig build test`

Opinionated defaults: native CPU target, release builds use full LTO and are stripped. Coverage needs [kcov](https://github.com/SimonKagstrom/kcov) (`nix shell nixpkgs#kcov`).
