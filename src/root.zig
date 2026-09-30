//! Minimal library.
const std = @import("std");

/// Writes a greeting for `name` to `writer`.
pub fn greet(writer: *std.Io.Writer, name: []const u8) std.Io.Writer.Error!void {
    try writer.print("Hello, {s}!\n", .{name});
}

test greet {
    var buf: [64]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buf);
    try greet(&writer, "world");
    try std.testing.expectEqualStrings("Hello, world!\n", writer.buffered());
}
