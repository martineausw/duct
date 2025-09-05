const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");

const get = @import("../../../get.zig");
const prototype = @import("../../../prototype.zig");
const scl_func = @import("../../ops.zig").scl_func;

pub fn new(comptime T: type) type {
    return struct {
        pub fn map(
            allocator: Allocator,
            data: anytype,
            scalar: anytype,
            func: *const fn (
                scalar: @TypeOf(scalar),
                element: meta.Elem(@TypeOf(data)),
                index: usize,
                data: *const @TypeOf(data),
            ) T,
        ) Allocator.Error![]T {
            const result = try allocator.alloc(T, get.len(data));

            for (0..result.len) |index| {
                result[index] = func(
                    scalar,
                    get.at(data, index),
                    index,
                    &data,
                );
            }

            return result;
        }

        pub fn add(
            allocator: Allocator,
            data: anytype,
            scalar: T,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).add,
            );
        }

        pub fn sub(
            allocator: Allocator,
            data: anytype,
            scalar: T,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).sub,
            );
        }

        pub fn mul(
            allocator: Allocator,
            data: anytype,
            scalar: T,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).mul,
            );
        }

        pub fn div(
            allocator: Allocator,
            data: anytype,
            scalar: T,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).div,
            );
        }

        pub fn divFloor(
            allocator: Allocator,
            data: anytype,
            scalar: T,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).divFloor,
            );
        }

        pub fn divCeil(
            allocator: Allocator,
            data: anytype,
            scalar: T,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).divCeil,
            );
        }
    };
}

test "add" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try new(usize).add(testing.allocator, slice, 1);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 2, 3, 4 }, result);
}

test "sub" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try new(usize).sub(testing.allocator, slice, 1);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, result);
}

test "mul" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try new(usize).mul(testing.allocator, slice, 2);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, result);
}

test "div" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try new(usize).div(testing.allocator, slice, 1);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, result);
}

test "divFloor" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try new(usize).divFloor(testing.allocator, slice, 2);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 0, 1, 1 }, result);
}

test "divCeil" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    const result = try new(usize).divCeil(testing.allocator, slice, 2);
    defer testing.allocator.free(result);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 2 }, result);
}
