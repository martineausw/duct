const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const Element = @import("../../../math.zig").Element;

const ziggurat = @import("ziggurat");

const get = @import("../../../get.zig");
const set = @import("../../../set.zig");
const prototype = @import("../../../prototype.zig");

pub fn map(
    comptime T: type,
    dest: anytype,
    aux: anytype,
    func: *const fn (
        elements: struct { meta.Elem(@TypeOf(dest.*)), meta.Elem(@TypeOf(aux)) },
        index: usize,
        data: struct { @TypeOf(dest.*), @TypeOf(aux) },
    ) T,
) ziggurat.sign(.seq(&.{
    prototype.has_len,
    prototype.has_len,
}))(.{
    @TypeOf(dest.*),
    @TypeOf(aux),
})(void) {
    for (0..dest.len) |index| {
        set.set(dest.*, index, func(
            .{ get.at(dest.*, index), get.at(aux, index) },
            index,
            .{ dest.*, aux },
        ));
    }
}

pub fn add(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return map(
        T,
        dest,
        aux,
        Element(T, @TypeOf(dest.*), @TypeOf(aux)).add,
    );
}

pub fn sub(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return map(
        T,
        dest,
        aux,
        Element(T, @TypeOf(dest.*), @TypeOf(aux)).sub,
    );
}

pub fn mul(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return map(
        T,
        dest,
        aux,
        Element(T, @TypeOf(dest.*), @TypeOf(aux)).mul,
    );
}

pub fn div(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return map(
        T,
        dest,
        aux,
        Element(T, @TypeOf(dest.*), @TypeOf(aux)).div,
    );
}

pub fn divFloor(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return map(
        T,
        dest,
        aux,
        Element(T, @TypeOf(dest.*), @TypeOf(aux)).divFloor,
    );
}

pub fn divCeil(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return map(
        T,
        dest,
        aux,
        Element(T, @TypeOf(dest.*), @TypeOf(aux)).divCeil,
    );
}

test "add" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    add(usize, &slice, slice);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
}

test "sub" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    sub(usize, &slice, slice);

    try testing.expectEqualSlices(usize, &.{ 0, 0, 0 }, slice);
}

test "mul" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    mul(usize, &slice, slice);

    try testing.expectEqualSlices(usize, &.{ 1, 4, 9 }, slice);
}

test "div" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    div(usize, &slice, slice);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, slice);
}

test "divFloor" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    divFloor(usize, &slice, slice);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, slice);
}

test "divCeil" {
    const slice = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    divCeil(usize, &slice, slice);

    try testing.expectEqualSlices(usize, &.{ 1, 1, 1 }, slice);
}
