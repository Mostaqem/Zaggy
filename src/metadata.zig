pub fn setMetadata(
    filePath: [:0]const u8,
    title: [:0]const u8,
    artist: [:0]const u8,
    album: [:0]const u8,
    genre: [:0]const u8,
) !void {
    const file = c.taglib_file_new(filePath);
    if (file == null) return error.OpenFailed;
    defer c.taglib_file_free(file);

    const tag = c.taglib_file_tag(file);
    if (tag == null) return error.NoTag;

    c.taglib_tag_set_title(tag, title);
    c.taglib_tag_set_artist(tag, artist);
    c.taglib_tag_set_album(tag, album);
    c.taglib_tag_set_genre(tag, genre);

    if (c.taglib_file_save(file) == 0) {
        return error.SaveFailed;
    }
}

pub const Metadata = struct {
    title: []u8,
    artist: []u8,
    album: []u8,
    genre: []u8,
    year: u32,
    track: u32,

    pub fn deinit(self: *Metadata, allocator: std.mem.Allocator) void {
        allocator.free(self.title);
        allocator.free(self.artist);
        allocator.free(self.album);
        allocator.free(self.genre);
    }
};

fn dupCStr(allocator: std.mem.Allocator, ptr: ?[*c]const u8) ![]u8 {
    if (ptr) |p| {
        return try allocator.dupe(u8, std.mem.span(p));
    }
    return try allocator.dupe(u8, "");
}

pub fn getMetadata(
    allocator: std.mem.Allocator,
    filePath: [:0]const u8,
) !Metadata {
    const file = c.taglib_file_new(filePath);
    if (file == null) return error.OpenFailed;
    defer c.taglib_file_free(file);

    const tag = c.taglib_file_tag(file);
    if (tag == null) return error.NoTag;

    const title_ptr = c.taglib_tag_title(tag);
    const artist_ptr = c.taglib_tag_artist(tag);
    const album_ptr = c.taglib_tag_album(tag);
    const genre_ptr = c.taglib_tag_genre(tag);

    const meta = Metadata{
        .title = try dupCStr(allocator, title_ptr),
        .artist = try dupCStr(allocator, artist_ptr),
        .album = try dupCStr(allocator, album_ptr),
        .genre = try dupCStr(allocator, genre_ptr),
        .year = c.taglib_tag_year(tag),
        .track = c.taglib_tag_track(tag),
    };

    c.taglib_tag_free_strings();

    return meta;
}

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("taggy_lib");

const c = @cImport({
    @cInclude("tag_c.h");
});
