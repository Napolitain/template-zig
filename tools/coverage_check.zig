//! Fails when kcov line coverage is below a minimum.
//! Usage: coverage_check <kcov-out-dir> <binary-name> <min-percent>
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len != 4) return error.Usage;
    const min = try std.fmt.parseFloat(f64, args[3]);

    const path = try std.fs.path.join(init.gpa, &.{ args[1], args[2], "coverage.json" });
    defer init.gpa.free(path);
    const json = try std.Io.Dir.cwd().readFileAlloc(init.io, path, init.gpa, .limited(1 << 24));
    defer init.gpa.free(json);

    const Report = struct { covered_lines: u64, total_lines: u64 };
    const report = try std.json.parseFromSlice(Report, init.gpa, json, .{ .ignore_unknown_fields = true });
    defer report.deinit();

    const r = report.value;
    const pct: f64 = if (r.total_lines == 0) 100 else 100 * @as(f64, @floatFromInt(r.covered_lines)) / @as(f64, @floatFromInt(r.total_lines));
    std.debug.print("line coverage {d:.2}% ({d}/{d}, min {d}%)\n", .{ pct, r.covered_lines, r.total_lines, min });
    if (pct < min) {
        std.debug.print("coverage below {d}%\n", .{min});
        std.process.exit(1);
    }
}
