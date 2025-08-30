const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");

const prototype = @import("prototype.zig");
const get = @import("get.zig");

pub inline fn set(
    data: anytype,
    index: usize,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(.all(&.{
    prototype.has_index,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    data[index] = value;
}

pub fn fill(
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(.all(&.{
    prototype.has_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    for (0..get.len(data)) |index| {
        set(data, index, value);
    }
}

pub fn ones(
    data: anytype,
) ziggurat.sign(.all(&.{
    prototype.has_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    fill(data, 1);
}

pub fn zeroes(
    data: anytype,
) ziggurat.sign(.all(&.{
    prototype.has_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    fill(data, 0);
}

pub fn transpose(
    allocator: Allocator,
    data: anytype,
    axes: []const usize,
) ziggurat.sign(.any(&.{
    prototype.has_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(Allocator.Error!void) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), get.len(data));

    for (0..get.len(data)) |index| {
        result[index] = get.at(data, axes[index]);
    }

    for (0..get.len(data)) |index| {
        set(data, index, result[index]);
    }

    allocator.free(result);
}

pub fn arange(
    data: anytype,
    start: meta.Elem(@TypeOf(data)),
    step: meta.Elem(@TypeOf(data)),
) ziggurat.sign(.all(&.{
    prototype.has_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    var value: usize = start;
    for (0..get.len(data)) |index| {
        set(data, index, value);
        value += step;
    }
}

test "set" {
    @setEvalBranchQuota(2000);
    const slice: []usize = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    set(slice, 0, 2);
    set(slice, 1, 4);
    set(slice, 2, 6);

    try testing.expectEqual(2, slice[0]);
    try testing.expectEqual(4, slice[1]);
    try testing.expectEqual(6, slice[2]);

    var vector: @Vector(3, usize) = .{ 1, 2, 3 };
    vector[0] = 1;

    set(&vector, 0, 2);
    set(&vector, 1, 4);
    set(&vector, 2, 6);

    try testing.expectEqual(2, vector[0]);
    try testing.expectEqual(4, vector[1]);
    try testing.expectEqual(6, vector[2]);

    var array: [3]usize = .{ 1, 2, 3 };
    array[0] = 1;

    set(&array, 0, 2);
    set(&array, 1, 4);
    set(&array, 2, 6);

    try testing.expectEqual(2, array[0]);
    try testing.expectEqual(4, array[1]);
    try testing.expectEqual(6, array[2]);
}
