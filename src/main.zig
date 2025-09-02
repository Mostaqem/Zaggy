//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var meta = try tag.getMetadata(allocator, "src/test.mp3");
    defer meta.deinit(allocator);

    std.debug.print("Title: {s}\n", .{meta.title});
}

const lib = @import("taggy_lib");
const std = @import("std");
const tag = @import("metadata.zig");
