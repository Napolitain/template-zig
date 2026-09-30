const std = @import("std");
const template = @import("template");

pub fn main(init: std.process.Init) !void {
    var buffer: [1024]u8 = undefined;
    var stdout: std.Io.File.Writer = .init(.stdout(), init.io, &buffer);
    try template.greet(&stdout.interface, "world");
    try stdout.interface.flush();
}
