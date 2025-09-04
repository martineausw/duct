const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");

const get = @import("../../../get.zig");
const prototype = @import("../../../prototype.zig");
const Scalar = @import("../../ops.zig").Scl;

pub fn map(
    allocator: Allocator,
    comptime T: type,
    data: anytype,
    scalar: T,
    func: *const fn (
        scalar: T,
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const result = try allocator.alloc(T, get.len(data));

    for (0..result.len) |index| {
        result[index] = func(
            scalar,
            get.at(data, index),
            index,
            data,
        );
    }

    return result;
}

pub fn add(
    allocator: Allocator,
    comptime T: type,
    data: anytype,
    scalar: T,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data)).add,
    );
}

pub fn sub(
    allocator: Allocator,
    comptime T: type,
    data: anytype,
    scalar: T,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data)).sub,
    );
}

pub fn mul(
    allocator: Allocator,
    comptime T: type,
    data: anytype,
    scalar: T,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data)).mul,
    );
}

pub fn div(
    allocator: Allocator,
    comptime T: type,
    data: anytype,
    scalar: T,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data)).div,
    );
}

pub fn divFloor(
    allocator: Allocator,
    comptime T: type,
    data: anytype,
    scalar: T,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data)).divFloor,
    );
}

pub fn divCeil(
    allocator: Allocator,
    comptime T: type,
    data: anytype,
    scalar: T,
) Allocator.Error![]T {
    return map(
        allocator,
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data)).divCeil,
    );
}

test "add" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try add(testing.allocator, usize, slice, 1);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 2, 3, 4 }, result);
}

test "sub" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try sub(testing.allocator, usize, slice, 1);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, result);
}

test "mul" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try mul(testing.allocator, usize, slice, 2);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, result);
}

test "div" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try div(testing.allocator, usize, slice, 1);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, result);
}

test "divFloor" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try divFloor(testing.allocator, usize, slice, 2);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 0, 1, 1 }, result);
}

test "divCeil" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try divCeil(testing.allocator, usize, slice, 2);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 2 }, result);
}
