const std = @import("std");
const meta = std.meta;
const testing = std.testing;

const ziggurat = @import("ziggurat");

const base_get = @import("../../../get.zig");
const base_set = @import("../../../set.zig");
const prototype = @import("../../../prototype.zig");
const scl_func = @import("../../ops.zig").scl_func;

pub fn set(comptime T: type) type {
    return struct {
        pub fn map(
            data: anytype,
            scalar: T,
            func: *const fn (
                scalar: T,
                element: T,
                index: usize,
                data: @TypeOf(data.*),
            ) @TypeOf(scalar),
        ) void {
            for (0..data.len) |index| {
                base_set.set(data.*, index, func(
                    scalar,
                    base_get.at(data.*, index),
                    index,
                    data.*,
                ));
            }
        }

        pub fn add(
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                data,
                scalar,
                scl_func(T, @TypeOf(data.*)).add,
            );
        }

        pub fn sub(
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                data,
                scalar,
                scl_func(T, @TypeOf(data.*)).sub,
            );
        }

        pub fn mul(
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                data,
                scalar,
                scl_func(T, @TypeOf(data.*)).mul,
            );
        }

        pub fn div(
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                data,
                scalar,
                scl_func(T, @TypeOf(data.*)).div,
            );
        }

        pub fn divFloor(
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                data,
                scalar,
                scl_func(T, @TypeOf(data.*)).divFloor,
            );
        }

        pub fn divCeil(
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                data,
                scalar,
                scl_func(T, @TypeOf(data.*)).divCeil,
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

    set(usize).add(&slice, 2);

    try testing.expectEqualSlices(usize, &.{ 3, 4, 5 }, slice);
}

test "sub" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).sub(&slice, @as(usize, 1));

    try testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, slice);
}

test "mul" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).mul(&slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
}

test "div" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).div(&slice, @as(usize, 1));

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice);
}

test "divFloor" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).divFloor(&slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 0, 1, 1 }, slice);
}

test "divCeil" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).divCeil(&slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 1, 1, 2 }, slice);
}
