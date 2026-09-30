const std = @import("std");

pub fn build(b: *std.Build) void {
    // Target defaults to the host CPU (native).
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const release = optimize != .Debug;

    const mod = b.addModule("template", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "template",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .strip = release,
            .imports = &.{.{ .name = "template", .module = mod }},
        }),
    });
    if (release) exe.lto = .full;
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    b.step("run", "Run the app").dependOn(&run_cmd.step);

    const mod_tests = b.addTest(.{ .root_module = mod });
    const exe_tests = b.addTest(.{ .root_module = exe.root_module });
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&b.addRunArtifact(mod_tests).step);
    test_step.dependOn(&b.addRunArtifact(exe_tests).step);

    // Coverage via kcov: zig build coverage → zig-out/coverage/index.html
    // kcov needs LLVM-emitted DWARF, so build a dedicated test binary with the LLVM backend.
    const cov_tests = b.addTest(.{ .root_module = mod, .use_llvm = true });
    const cov = b.addSystemCommand(&.{ "kcov", "--clean", "--include-pattern=/src/" });
    cov.addArg(b.getInstallPath(.prefix, "coverage"));
    cov.addArtifactArg(cov_tests);
    b.step("coverage", "Run tests under kcov").dependOn(&cov.step);
}
