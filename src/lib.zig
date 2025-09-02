pub export fn setMetadata(
    filePath: [*c]const u8,
    title: [*c]const u8,
    artist: [*c]const u8,
    album: [*c]const u8,
    genre: [*c]const u8,
) c_int {
    const file = c.taglib_file_new(filePath);
    if (file == null) return -1;
    defer c.taglib_file_free(file);

    const tag = c.taglib_file_tag(file);
    if (tag == null) return -2;
    c.taglib_tag_set_title(tag, title);
    c.taglib_tag_set_artist(tag, artist);
    c.taglib_tag_set_album(tag, album);
    c.taglib_tag_set_genre(tag, genre);

    if (c.taglib_file_save(file) == 0) return -3;

    return 0;
}

pub const Metadata = extern struct {
    title: [*c]u8,
    artist: [*c]u8,
    album: [*c]u8,
    genre: [*c]u8,
    year: c_uint,
    track: c_uint,
};

extern fn malloc(size: usize) callconv(.C) ?*anyopaque;
extern fn free(ptr: ?*anyopaque) callconv(.C) void;

fn dupCStr(ptr: [*c]const u8) ?[*c]u8 {
    if (ptr == null) return null;

    const len = std.mem.len(ptr);
    const raw = malloc(len + 1) orelse return null;

    // correct way to cast malloc’s pointer to a C string pointer
    const buf: [*c]u8 = @ptrCast(raw);

    @memcpy(buf[0..len], ptr[0..len]);
    buf[len] = 0;
    return buf;
}

pub export fn getMetadata(filePath: [*c]const u8) Metadata {
    const file = c.taglib_file_new(filePath);
    if (file == null) return Metadata{ .title = null, .artist = null, .album = null, .genre = null, .year = 0, .track = 0 };
    defer c.taglib_file_free(file);

    const tag = c.taglib_file_tag(file);
    if (tag == null) return Metadata{ .title = null, .artist = null, .album = null, .genre = null, .year = 0, .track = 0 };

    const meta = Metadata{
        .title = dupCStr(c.taglib_tag_title(tag)) orelse null,
        .artist = dupCStr(c.taglib_tag_artist(tag)) orelse null,
        .album = dupCStr(c.taglib_tag_album(tag)) orelse null,
        .genre = dupCStr(c.taglib_tag_genre(tag)) orelse null,
        .year = c.taglib_tag_year(tag),
        .track = c.taglib_tag_track(tag),
    };

    // taglib allocates internal strings → must free them
    c.taglib_tag_free_strings();

    return meta;
}

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("taggy_lib");

const c = @cImport({
    @cInclude("tag_c.h");
});
