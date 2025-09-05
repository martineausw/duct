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
            a: anytype,
            b: anytype,
            func: *const fn (
                elements: struct { meta.Elem(@TypeOf(a)), meta.Elem(@TypeOf(b)) },
                index: usize,
                data: struct { *const @TypeOf(a), *const @TypeOf(b) },
            ) T,
        ) void {
            for (0..dest.len) |index| {
                base_set.set(dest.*, index, func(
                    .{ base_get.at(a, index), base_get.at(b, index) },
                    index,
                    .{ &a, &b },
                ));
            }
        }

        pub fn add(
            dest: anytype,
            a: anytype,
            b: anytype,
        ) void {
            return map(
                dest,
                a,
                b,
                elm_func(T, @TypeOf(a), @TypeOf(b)).add,
            );
        }

        pub fn sub(
            dest: anytype,
            a: anytype,
            b: anytype,
        ) void {
            return map(
                dest,
                a,
                b,
                elm_func(T, @TypeOf(a), @TypeOf(b)).sub,
            );
        }

        pub fn mul(
            dest: anytype,
            a: anytype,
            b: anytype,
        ) void {
            return map(
                dest,
                a,
                b,
                elm_func(T, @TypeOf(a), @TypeOf(b)).mul,
            );
        }

        pub fn div(
            dest: anytype,
            a: anytype,
            b: anytype,
        ) void {
            return map(
                dest,
                a,
                b,
                elm_func(T, @TypeOf(a), @TypeOf(b)).div,
            );
        }

        pub fn divFloor(
            dest: anytype,
            a: anytype,
            b: anytype,
        ) void {
            return map(
                dest,
                a,
                b,
                elm_func(T, @TypeOf(a), @TypeOf(b)).divFloor,
            );
        }

        pub fn divCeil(
            dest: anytype,
            a: anytype,
            b: anytype,
        ) void {
            return map(
                dest,
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

    const result = try allocator.alloc(f32, 6);

    set(f32).map(
        &result,
        a,
        b,
        elm_func(f32, []const f32, []const f32).add,
    );

    allocator.free(a);
    allocator.free(b);

    try testing.expectEqualSlices(f32, &.{ 2, 4, 6, 8, 10, 12 }, result);

    allocator.free(result);
}
