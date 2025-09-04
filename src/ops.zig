const std = @import("std");

const get = @import("get.zig");

pub inline fn add(
    comptime Result: type,
    a: anytype,
    b: anytype,
) Result {
    return get.numCast(Result, a) + get.numCast(Result, b);
}

pub inline fn sub(
    comptime Result: type,
    a: anytype,
    b: anytype,
) Result {
    return get.numCast(Result, a) - get.numCast(Result, b);
}

pub inline fn mul(
    comptime Result: type,
    a: anytype,
    b: anytype,
) Result {
    return get.numCast(Result, a) * get.numCast(Result, b);
}

pub inline fn div(
    comptime Result: type,
    a: anytype,
    b: anytype,
) Result {
    return get.numCast(Result, a) / get.numCast(Result, b);
}

pub inline fn divFloor(
    comptime Result: type,
    a: anytype,
    b: anytype,
) Result {
    return std.math.divFloor(Result, get.numCast(Result, a), get.numCast(Result, b)) catch unreachable;
}

pub inline fn divCeil(
    comptime Result: type,
    a: anytype,
    b: anytype,
) Result {
    return std.math.divCeil(Result, get.numCast(Result, a), get.numCast(Result, b)) catch unreachable;
}
