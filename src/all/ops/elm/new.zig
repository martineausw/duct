const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");

const get = @import("../../../get.zig");
const prototype = @import("../../../prototype.zig");
const elm_func = @import("../../ops.zig").elm_func;

pub fn new(comptime T: type) type {
    return struct {
        pub fn map(
            allocator: Allocator,
            a: anytype,
            b: anytype,
            func: *const fn (
                elements: struct { meta.Elem(@TypeOf(a)), meta.Elem(@TypeOf(b)) },
                index: usize,
                data: struct { *const @TypeOf(a), *const @TypeOf(b) },
            ) T,
        ) Allocator.Error![]T {
            const result = try allocator.alloc(T, get.len(a));

            for (0..result.len) |index| {
                result[index] = func(
                    .{ get.at(a, index), get.at(b, index) },
                    index,
                    .{ &a, &b },
                );
            }

            return result;
        }

        pub fn add(
            allocator: Allocator,
            data_0: anytype,
            data_1: anytype,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data_0,
                data_1,
                elm_func(T, @TypeOf(data_0), @TypeOf(data_1)).add,
            );
        }

        pub fn sub(
            allocator: Allocator,
            data_0: anytype,
            data_1: anytype,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data_0,
                data_1,
                elm_func(T, @TypeOf(data_0), @TypeOf(data_1)).sub,
            );
        }

        pub fn mul(
            allocator: Allocator,
            data_0: anytype,
            data_1: anytype,
        ) Allocator.Error![]T {
            return map(
                allocator,
                data_0,
                data_1,
                elm_func(T, @TypeOf(data_0), @TypeOf(data_1)).mul,
            );
        }

        pub fn div(
            allocator: Allocator,
            a: anytype,
            b: anytype,
        ) Allocator.Error![]T {
            return map(
                allocator,
                a,
                b,
                elm_func(T, @TypeOf(a), @TypeOf(b)).div,
            );
        }

        pub fn divFloor(
            allocator: Allocator,
            a: anytype,
            b: anytype,
        ) Allocator.Error![]T {
            return map(
                allocator,
                a,
                b,
                elm_func(T, @TypeOf(a), @TypeOf(b)).divFloor,
            );
        }

        pub fn divCeil(
            allocator: Allocator,
            a: anytype,
            b: anytype,
        ) Allocator.Error![]T {
            return map(
                allocator,
                a,
                b,
                elm_func(T, @TypeOf(a), @TypeOf(b)).divCeil,
            );
        }
    };
}

test "map slices" {
    const allocator = testing.allocator;

    const a = try allocator.alloc(f32, 6);
    const b = try allocator.alloc(f32, 6);

    for (0..a.len) |i| a[i] = @floatFromInt(i + 1);
    for (0..b.len) |i| b[i] = @floatFromInt(i + 1);

    const result = try new(f32).map(
        allocator,
        a,
        b,
        elm_func(f32, []const f32, []const f32).add,
    );

    allocator.free(a);
    allocator.free(b);

    try testing.expectEqualSlices(f32, &.{ 2, 4, 6, 8, 10, 12 }, result);

    allocator.free(result);
}

test "map slice and array" {
    const allocator = testing.allocator;

    const a = try allocator.alloc(f32, 6);
    const b = [_]f32{ 1, 2, 3, 4, 5, 6 };

    for (0..a.len) |i| a[i] = @floatFromInt(i + 1);

    const result = try new(f32).map(
        allocator,
        a,
        b,
        elm_func(f32, []const f32, [6]f32).add,
    );

    allocator.free(a);

    try testing.expectEqualSlices(f32, &.{ 2, 4, 6, 8, 10, 12 }, result);

    allocator.free(result);
}

test "map arrays" {
    const allocator = testing.allocator;

    const a = [_]f32{ 1, 2, 3, 4, 5, 6 };
    const b = [_]f32{ 1, 2, 3, 4, 5, 6 };

    const result = try new(f32).map(
        allocator,
        a,
        b,
        elm_func(f32, [6]f32, [6]f32).add,
    );

    try testing.expectEqualSlices(f32, &.{ 2, 4, 6, 8, 10, 12 }, result);

    allocator.free(result);
}

test "map ints and floats" {
    const allocator = testing.allocator;

    const a = try allocator.alloc(i32, 6);
    const b = try allocator.alloc(f32, 6);

    for (0..a.len) |i| a[i] = -1 * @as(i32, @intCast(i + 1));
    for (0..b.len) |i| b[i] = @floatFromInt(i + 1);

    const result = try new(f32).map(
        allocator,
        a,
        b,
        elm_func(f32, []const i32, []const f32).add,
    );

    allocator.free(a);
    allocator.free(b);

    try testing.expectEqualSlices(f32, &.{ 0, 0, 0, 0, 0, 0 }, result);

    allocator.free(result);
}
