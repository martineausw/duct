const std = @import("std");
const meta = std.meta;
const testing = std.testing;

const Scalar = @import("../../../math.zig").Scalar;

const get = @import("../../../get.zig");
const set = @import("../../../set.zig");
const prototype = @import("../../../prototype.zig");
const ziggurat = @import("ziggurat");

pub fn map(
    comptime T: type,
    data: anytype,
    scalar: T,
    func: *const fn (
        scalar: @TypeOf(scalar),
        elements: meta.Elem(@TypeOf(data.*)),
        index: usize,
        data: @TypeOf(data.*),
    ) T,
) ziggurat.sign(.seq(&.{
    prototype.is_number,
    prototype.has_len,
    prototype.is_number,
}))(.{
    T,
    @TypeOf(data.*),
    @TypeOf(scalar),
})(void) {
    for (0..data.len) |index| {
        set.set(data.*, index, func(
            scalar,
            get.at(data.*, index),
            index,
            data.*,
        ));
    }
}

pub fn add(
    comptime T: type,
    data: anytype,
    scalar: anytype,
) void {
    return map(
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data.*)).add,
    );
}

pub fn sub(
    comptime T: type,
    data: anytype,
    scalar: anytype,
) void {
    return map(
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data.*)).sub,
    );
}

pub fn mul(
    comptime T: type,
    data: anytype,
    scalar: anytype,
) void {
    return map(
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data.*)).mul,
    );
}

pub fn div(
    comptime T: type,
    data: anytype,
    scalar: anytype,
) void {
    return map(
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data.*)).div,
    );
}

pub fn divFloor(
    comptime T: type,
    data: anytype,
    scalar: anytype,
) void {
    return map(
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data.*)).divFloor,
    );
}

pub fn divCeil(
    comptime T: type,
    data: anytype,
    scalar: anytype,
) void {
    return map(
        T,
        data,
        scalar,
        Scalar(T, @TypeOf(data.*)).divCeil,
    );
}

test "addScalar" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    add(usize, &slice, 2);

    try testing.expectEqualSlices(usize, &.{ 3, 4, 5 }, slice);
}

test "subScalar" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    sub(usize, &slice, @as(usize, 1));

    try testing.expectEqualSlices(usize, &.{ 0, 1, 2 }, slice);
}

test "mulScalar" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    mul(usize, &slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
}

test "divScalar" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    div(usize, &slice, @as(usize, 1));

    try testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, slice);
}

test "divFloorScalar" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    divFloor(usize, &slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 0, 1, 1 }, slice);
}

test "divCeilScalar" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    divCeil(usize, &slice, @as(usize, 2));

    try testing.expectEqualSlices(usize, &.{ 1, 1, 2 }, slice);
}
