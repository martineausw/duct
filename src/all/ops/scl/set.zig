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
            dest: anytype,
            data: anytype,
            scalar: anytype,
            func: *const fn (
                scalar: @TypeOf(scalar),
                element: meta.Elem(@TypeOf(data)),
                index: usize,
                data: *const @TypeOf(data),
            ) T,
        ) void {
            for (0..data.len) |index| {
                base_set.set(dest, index, func(
                    scalar,
                    base_get.at(data, index),
                    index,
                    &data,
                ));
            }
        }

        pub fn add(
            dest: anytype,
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                dest,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).add,
            );
        }

        pub fn sub(
            dest: anytype,
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                dest,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).sub,
            );
        }

        pub fn mul(
            dest: anytype,
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                dest,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).mul,
            );
        }

        pub fn div(
            dest: anytype,
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                dest,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).div,
            );
        }

        pub fn divFloor(
            dest: anytype,
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                dest,
                data,
                scalar,
                scl_func(T, @TypeOf(data)).divFloor,
            );
        }

        pub fn divCeil(
            dest: anytype,
            data: anytype,
            scalar: anytype,
        ) void {
            return map(
                dest,
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

    set(usize).add(slice, slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 3, 4, 5 }, slice);
}

test "sub" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).sub(slice, slice, @as(usize, 1));

    try testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, slice);
}

test "mul" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).mul(slice, slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
}

test "div" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).div(slice, slice, @as(usize, 1));

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice);
}

test "divFloor" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).divFloor(slice, slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 0, 1, 1 }, slice);
}

test "divCeil" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).divCeil(slice, slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 1, 1, 2 }, slice);
}
