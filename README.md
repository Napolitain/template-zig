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

## Optional Nix shell

Installing the tools directly on NixOS (or another OS) remains supported. The
optional shell supports x86_64/aarch64 Linux and Apple Silicon macOS. With Nix
flakes enabled:

```sh
nix develop --command "$SHELL"       # keep your shell, aliases and prompt
# Or: nix develop                   # use Nix's default Bash shell
```

Then run the normal development commands in this README. Each template has its own
`flake.nix` and `flake.lock`, using `github:NixOS/nixpkgs/nixpkgs-unstable`.
To refresh to the latest unstable packages, run `nix flake update nixpkgs`,
then leave and re-enter the shell. Commit the updated lock file with your project.

The shell supplies Zig and, on Linux, kcov for coverage. The coverage command
requires Linux; building and running tests also work on macOS.

## Coverage

[kcov](https://github.com/SimonKagstrom/kcov) (`nix shell nixpkgs#kcov`, `apt install kcov`) runs on pre-push and in CI. Coverage of `src/` (library tests) fails below 80% lines; override with `zig build coverage -Dcoverage-min=90`. The check is `tools/coverage_check.zig`, reading kcov's `coverage.json`.

## Profile-guided optimization

No supported PGO workflow is exposed for Zig sources by this template's Zig 0.16
CLI/build API. Instrumentation generate/use, sampling/AutoFDO and Propeller-style
layout/relinking are therefore not supplied. `zig build-exe --help` exposes LLVM
backend and LTO switches, but that does not imply profile generation or consumption.
Clang flags accepted by `zig cc` for C/C++ do not enable PGO for `src/*.zig`.

Continue using `zig build -Doptimize=ReleaseFast`. Measure realistic workloads
with repeated runs before changing optimization settings. kcov measures test
coverage; its output is not an optimization profile. Reassess support when changing
Zig versions against the [Zig source and build API](https://github.com/ziglang/zig).
