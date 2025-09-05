const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");

const get = @import("get.zig");
const prototype = @import("prototype.zig");
const has_index_mutable = prototype.has_index_mutable;
const has_len_mutable = prototype.has_len_mutable;
const has_dynamic_len_mutable = prototype.has_dynamic_len_mutable;

pub const all = @import("all/set.zig");

pub inline fn set(
    dest: anytype,
    index: usize,
    value: meta.Elem(@TypeOf(dest)),
) ziggurat.sign(
    has_index_mutable,
)(@TypeOf(dest))(void) {
    dest[index] = value;
}

pub fn fill(
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(
    has_len_mutable,
)(@TypeOf(data))(void) {
    for (0..get.len(data)) |index| {
        set(data, index, value);
    }
}

pub fn ones(
    data: anytype,
) ziggurat.sign(
    has_len_mutable,
)(@TypeOf(data))(void) {
    fill(data, 1);
}

pub fn zeroes(
    data: anytype,
) ziggurat.sign(
    has_len_mutable,
)(@TypeOf(data))(void) {
    fill(data, 0);
}

pub fn transpose(
    allocator: Allocator,
    data: anytype,
    axes: []const usize,
) ziggurat.sign(
    has_index_mutable,
)(@TypeOf(data))(Allocator.Error!void) {
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
    step: @TypeOf(start),
    end: @TypeOf(step),
) ziggurat.sign(
    has_index_mutable,
)(@TypeOf(data))(void) {
    var value: meta.Elem(@TypeOf(data)) = start;
    var index: usize = 0;
    while (value < end) : (value += step) {
        set(data, index, value);
        index += 1;
    }
}

pub fn remove(
    allocator: Allocator,
    data: anytype,
    index: usize,
) ziggurat.sign(
    has_dynamic_len_mutable,
)(@TypeOf(data))(Allocator.Error!meta.Elem(@TypeOf(data.*))) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data.*)), get.len(data.*) - 1);
    const return_value: meta.Elem(@TypeOf(data.*)) = get.at(data.*, index);

    var result_index: usize = 0;
    for (0..get.len(data.*)) |i| {
        if (i == index) {
            continue;
        }

        result[result_index] = get.at(data.*, i);
        result_index += 1;
    }

    allocator.free(data.*);
    data.* = result;

    return return_value;
}

pub fn insert(
    allocator: Allocator,
    data: anytype,
    index: usize,
    value: meta.Elem(@TypeOf(data.*)),
) ziggurat.sign(
    has_dynamic_len_mutable,
)(@TypeOf(data))(Allocator.Error!void) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data.*)), get.len(data.*) + 1);

    var data_index: usize = 0;
    for (0..get.len(data.*) + 1) |i| {
        if (i == index) {
            result[i] = value;
            continue;
        }

        result[i] = get.at(data.*, data_index);
        data_index += 1;
    }

    allocator.free(data.*);
    data.* = result;
}

pub fn push(
    allocator: Allocator,
    data: anytype,
    value: meta.Elem(@TypeOf(data.*)),
) ziggurat.sign(
    has_dynamic_len_mutable,
)(@TypeOf(data))(Allocator.Error!void) {
    return insert(allocator, data, get.len(data.*), value);
}

pub fn unshift(
    allocator: Allocator,
    data: anytype,
    value: meta.Elem(@TypeOf(data.*)),
) ziggurat.sign(
    has_dynamic_len_mutable,
)(@TypeOf(data))(Allocator.Error!void) {
    return insert(allocator, data, 0, value);
}

pub fn pop(
    allocator: Allocator,
    data: anytype,
) ziggurat.sign(
    has_dynamic_len_mutable,
)(@TypeOf(data))(Allocator.Error!meta.Elem(@TypeOf(data.*))) {
    return remove(allocator, data, get.len(data.*) - 1);
}

pub fn shift(
    allocator: Allocator,
    data: anytype,
) ziggurat.sign(
    has_dynamic_len_mutable,
)(@TypeOf(data))(Allocator.Error!meta.Elem(@TypeOf(data.*))) {
    return remove(allocator, data, 0);
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

test "insert" {
    var slice: []usize = try testing.allocator.alloc(usize, 2);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 3;

    try insert(testing.allocator, &slice, 1, 2);

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice);
}

test "push" {
    var slice: []usize = try testing.allocator.alloc(usize, 2);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;

    try push(testing.allocator, &slice, 3);

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice);
}

test "unshift" {
    var slice: []usize = try testing.allocator.alloc(usize, 2);
    defer testing.allocator.free(slice);

    slice[0] = 2;
    slice[1] = 3;

    try unshift(testing.allocator, &slice, 1);

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice);
}

test "remove" {
    var slice: []usize = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    _ = try remove(testing.allocator, &slice, 1);

    try testing.expectEqualSlices(usize, &.{ 1, 3 }, slice);
}

test "pop" {
    var slice: []usize = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    _ = try pop(testing.allocator, &slice);

    try testing.expectEqualSlices(usize, &.{ 1, 2 }, slice);
}

test "shift" {
    var slice: []usize = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    _ = try shift(testing.allocator, &slice);

    try testing.expectEqualSlices(usize, &.{ 2, 3 }, slice);
}
