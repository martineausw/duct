const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");

const get = @import("../../../get.zig");
const prototype = @import("../../../prototype.zig");
const Element = @import("../../ops.zig").Elm;

pub fn map(
    allocator: Allocator,
    comptime T: type,
    data_0: anytype,
    data_1: anytype,
    func: *const fn (
        elements: struct { meta.Elem(@TypeOf(data_0)), meta.Elem(@TypeOf(data_1)) },
        index: usize,
        data: struct { @TypeOf(data_0), @TypeOf(data_1) },
    ) T,
) ziggurat.sign(.seq(&.{
    prototype.has_len,
    prototype.has_len,
}))(.{
    @TypeOf(data_0),
    @TypeOf(data_1),
})(Allocator.Error![]T) {
    const result = try allocator.alloc(T, get.len(data_0));

    for (0..result.len) |index| {
        result[index] = func(
            .{ get.at(data_0, index), get.at(data_1, index) },
            index,
            .{ data_0, data_1 },
        );
    }

    return result;
}

pub fn add(
    allocator: Allocator,
    comptime T: type,
    data_0: anytype,
    data_1: anytype,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data_0,
        data_1,
        Element(T, @TypeOf(data_0), @TypeOf(data_1)).add,
    );
}

pub fn sub(
    allocator: Allocator,
    comptime T: type,
    data_0: anytype,
    data_1: anytype,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data_0,
        data_1,
        Element(T, @TypeOf(data_0), @TypeOf(data_1)).sub,
    );
}

pub fn mul(
    allocator: Allocator,
    comptime T: type,
    data_0: anytype,
    data_1: anytype,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data_0,
        data_1,
        Element(T, @TypeOf(data_0), @TypeOf(data_1)).mul,
    );
}

pub fn div(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        a,
        b,
        Element(T, @TypeOf(a), @TypeOf(b)).div,
    );
}

pub fn divFloor(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        a,
        b,
        Element(T, @TypeOf(a), @TypeOf(b)).divFloor,
    );
}

pub fn divCeil(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        a,
        b,
        Element(T, @TypeOf(a), @TypeOf(b)).divCeil,
    );
}

test "add" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try add(testing.allocator, usize, slice, slice);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, result);
}

test "sub" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try sub(testing.allocator, usize, slice, slice);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 0, 0, 0 }, result);
}

test "mul" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try mul(testing.allocator, usize, slice, slice);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 1, 4, 9 }, result);
}

test "div" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try div(testing.allocator, usize, slice, slice);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, result);
}

test "divFloor" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try divFloor(testing.allocator, usize, slice, slice);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, result);
}

test "divCeil" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try divCeil(testing.allocator, usize, slice, slice);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, result);
}
