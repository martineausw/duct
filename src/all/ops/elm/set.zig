const std = @import("std");
const meta = std.meta;
const testing = std.testing;

const ziggurat = @import("ziggurat");

const base_get = @import("../../../get.zig");
const base_set = @import("../../../set.zig");
const prototype = @import("../../../prototype.zig");
const elm_func = @import("../../ops.zig").elm_func;

pub fn set(comptime T: type) type {
    return struct {
        pub fn map(
            dest: anytype,
            aux: anytype,
            func: *const fn (
                elements: struct { T, T },
                index: usize,
                data: struct { @TypeOf(dest.*), @TypeOf(aux) },
            ) T,
        ) void {
            for (0..dest.len) |index| {
                base_set.set(dest.*, index, func(
                    .{ base_get.at(dest.*, index), base_get.at(aux, index) },
                    index,
                    .{ dest.*, aux },
                ));
            }
        }

        pub fn add(
            dest: anytype,
            aux: anytype,
        ) void {
            return map(
                dest,
                aux,
                elm_func(T, @TypeOf(dest.*), @TypeOf(aux)).add,
            );
        }

        pub fn sub(
            dest: anytype,
            aux: anytype,
        ) void {
            return map(
                dest,
                aux,
                elm_func(T, @TypeOf(dest.*), @TypeOf(aux)).sub,
            );
        }

        pub fn mul(
            dest: anytype,
            aux: anytype,
        ) void {
            return map(
                dest,
                aux,
                elm_func(T, @TypeOf(dest.*), @TypeOf(aux)).mul,
            );
        }

        pub fn div(
            dest: anytype,
            aux: anytype,
        ) void {
            return map(
                dest,
                aux,
                elm_func(T, @TypeOf(dest.*), @TypeOf(aux)).div,
            );
        }

        pub fn divFloor(
            dest: anytype,
            aux: anytype,
        ) void {
            return map(
                dest,
                aux,
                elm_func(T, @TypeOf(dest.*), @TypeOf(aux)).divFloor,
            );
        }

        pub fn divCeil(
            dest: anytype,
            aux: anytype,
        ) void {
            return map(
                dest,
                aux,
                elm_func(T, @TypeOf(dest.*), @TypeOf(aux)).divCeil,
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

    set(usize).add(&slice, slice);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
}

test "sub" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).sub(&slice, slice);

    try testing.expectEqualSlices(usize, &.{ 0, 0, 0 }, slice);
}

test "mul" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).mul(&slice, slice);

    try testing.expectEqualSlices(usize, &.{ 1, 4, 9 }, slice);
}

test "div" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).div(&slice, slice);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, slice);
}

test "divFloor" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).divFloor(&slice, slice);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, slice);
}

test "divCeil" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    set(usize).divCeil(&slice, slice);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, slice);
}
