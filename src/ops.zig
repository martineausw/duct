const std = @import("std");

const get = @import("get.zig");

pub inline fn add(
    comptime T: type,
    a: anytype,
    b: anytype,
) T {
    return get.numCast(T, a) + get.numCast(T, b);
}

pub inline fn sub(
    comptime T: type,
    a: anytype,
    b: anytype,
) T {
    return get.numCast(T, a) - get.numCast(T, b);
}

pub inline fn mul(
    comptime T: type,
    a: anytype,
    b: anytype,
) T {
    return get.numCast(T, a) * get.numCast(T, b);
}

pub inline fn div(
    comptime T: type,
    a: anytype,
    b: anytype,
) T {
    return get.numCast(T, a) / get.numCast(T, b);
}

pub inline fn divFloor(
    comptime T: type,
    a: anytype,
    b: anytype,
) T {
    return std.math.divFloor(T, get.numCast(T, a), get.numCast(T, b)) catch unreachable;
}

pub inline fn divCeil(
    comptime T: type,
    a: anytype,
    b: anytype,
) T {
    return std.math.divCeil(T, get.numCast(T, a), get.numCast(T, b)) catch unreachable;
}
