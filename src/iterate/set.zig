const std = @import("std");
const testing = std.testing;
const meta = std.meta;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");
const prototype = @import("../prototype.zig");

const get = @import("../get.zig");
const set = @import("../set.zig");

pub fn map(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) ziggurat.sign(.all(&.{
    prototype.has_len,
    .not(.is_array(.{})),
    .not(.is_pointer(.{})),
}))(@TypeOf(data))(void) {
    for (0..get.len(data)) |index| {
        set(
            data,
            index,
            func(get.at(data, index), index, data),
        );
    }
}

test "map" {
    const array_func = struct {
        pub fn call(element: usize, _: usize, _: *[3]usize) usize {
            return element * 2;
        }
    };

    const vector_func = struct {
        pub fn call(element: usize, _: usize, _: *@Vector(3, usize)) usize {
            return element * 2;
        }
    };

    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []usize) usize {
            return element * 2;
        }
    };

    const array = try testing.allocator.create([3]usize);
    const vector = try testing.allocator.create(@Vector(3, usize));
    const slice: []usize = try testing.allocator.alloc(usize, 3);

    defer testing.allocator.destroy(array);
    defer testing.allocator.destroy(vector);
    defer testing.allocator.free(slice);

    array.* = .{ 1, 2, 3 };
    vector.* = .{ 1, 2, 3 };
    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    map(array, array_func.call);
    map(vector, vector_func.call);
    map(slice, slice_func.call);

    try testing.expectEqualDeep([_]usize{ 2, 4, 6 }, array.*);
    try testing.expectEqualDeep(@Vector(3, usize){ 2, 4, 6 }, vector.*);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
}
