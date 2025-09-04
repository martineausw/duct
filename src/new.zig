const std = @import("std");
const testing = std.testing;
const meta = std.meta;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");
const prototype = @import("prototype.zig");

const get = @import("get.zig");
const set = @import("set.zig");

pub const all = @import("all/new.zig");

pub fn fill(
    allocator: Allocator,
    n: usize,
    value: anytype,
) ziggurat.sign(.any(&.{
    .is_int(.{}),
    .is_float(.{}),
    .is_bool,
}))(@TypeOf(value))(Allocator.Error![]@TypeOf(value)) {
    const result = try allocator.alloc(@TypeOf(value), n);
    set.fill(result, value);
    return result;
}

pub fn zeroes(
    allocator: Allocator,
    T: type,
    n: usize,
) ziggurat.sign(.any(&.{
    .is_int(.{}),
    .is_float(.{}),
    .is_bool,
}))(T)(Allocator.Error![]T) {
    const result = try allocator.alloc(T, n);
    set.zeroes(result);
    return result;
}

pub fn ones(
    allocator: Allocator,
    T: type,
    n: usize,
) ziggurat.sign(.any(&.{
    .is_int(.{}),
    .is_float(.{}),
    .is_bool,
}))(T)(Allocator.Error![]T) {
    const result = try allocator.alloc(T, n);
    set.ones(result);
    return result;
}

pub fn arange(
    allocator: Allocator,
    n: usize,
    start: anytype,
    step: @TypeOf(start),
) ziggurat.sign(
    .any(&.{
        .is_float(.{}),
        .is_int(.{}),
    }),
)(@TypeOf(start))(Allocator.Error![]@TypeOf(start)) {
    const result = try allocator.alloc(@TypeOf(start), n);
    set.arange(result, start, step);
    return result;
}

pub fn remove(
    allocator: Allocator,
    data: anytype,
    index: usize,
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), get.len(data) - 1);

    var result_index: usize = 0;
    for (0..get.len(data)) |i| {
        if (i == index) {
            continue;
        }

        result[result_index] = get.at(data, i);
        result_index += 1;
    }

    return result;
}

pub fn insert(
    allocator: Allocator,
    data: anytype,
    index: usize,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), get.len(data) + 1);

    var data_index: usize = 0;
    for (0..get.len(data) + 1) |i| {
        if (i == index) {
            result[i] = value;
            continue;
        }

        result[i] = get.at(data, data_index);
        data_index += 1;
    }

    return result;
}

pub fn push(
    allocator: Allocator,
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    return insert(allocator, data, get.len(data), value);
}

pub fn unshift(
    allocator: Allocator,
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    return insert(allocator, data, 0, value);
}

pub fn pop(
    allocator: Allocator,
    data: anytype,
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    return remove(allocator, data, get.len(data) - 1);
}

pub fn shift(
    allocator: Allocator,
    data: anytype,
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    return remove(allocator, data, 0);
}

pub fn copy(
    allocator: Allocator,
    data: anytype,
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), get.len(data));

    for (0..result.len) |index| {
        result[index] = get.at(data, index);
    }

    return result;
}

test "insert" {
    const slice: []usize = try testing.allocator.alloc(usize, 2);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 3;

    const slice_inserted: []usize = try insert(testing.allocator, slice, 1, 2);
    defer testing.allocator.free(slice_inserted);

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice_inserted);
}

test "push" {
    const slice: []usize = try testing.allocator.alloc(usize, 2);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;

    const slice_inserted: []usize = try push(testing.allocator, slice, 3);
    defer testing.allocator.free(slice_inserted);

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice_inserted);
}

test "unshift" {
    const slice: []usize = try testing.allocator.alloc(usize, 2);
    defer testing.allocator.free(slice);

    slice[0] = 2;
    slice[1] = 3;

    const slice_inserted: []usize = try unshift(testing.allocator, slice, 1);
    defer testing.allocator.free(slice_inserted);

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice_inserted);
}

test "remove" {
    const slice: []usize = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const slice_removed: []usize = try remove(testing.allocator, slice, 1);
    defer testing.allocator.free(slice_removed);

    try testing.expectEqualSlices(usize, &.{ 1, 3 }, slice_removed);
}

test "pop" {
    const slice: []usize = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const slice_removed: []usize = try pop(testing.allocator, slice);
    defer testing.allocator.free(slice_removed);

    try testing.expectEqualSlices(usize, &.{ 1, 2 }, slice_removed);
}

test "shift" {
    const slice: []usize = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const slice_removed: []usize = try shift(testing.allocator, slice);
    defer testing.allocator.free(slice_removed);

    try testing.expectEqualSlices(usize, &.{ 2, 3 }, slice_removed);
}
