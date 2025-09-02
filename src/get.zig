const std = @import("std");
const testing = std.testing;
const meta = std.meta;

const ziggurat = @import("ziggurat");

const prototype = @import("prototype.zig");

pub const iterate = @import("iterate/get.zig");

pub inline fn at(
    data: anytype,
    index: usize,
) ziggurat.sign(prototype.has_index)(@TypeOf(data))(meta.Elem(@TypeOf(data))) {
    return data[index];
}

pub inline fn len(
    data: anytype,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(usize) {
    return switch (@typeInfo(@TypeOf(data))) {
        inline .array => data.len,
        inline .vector => |info| info.len,
        inline .pointer => |info| switch (info.size) {
            inline .one => switch (@typeInfo(info.child)) {
                inline .array => data.len,
                inline .vector => |vector_info| vector_info.len,
                else => unreachable,
            },
            inline .slice => data.len,
            inline .many, .c => std.mem.len(data),
        },
        else => unreachable,
    };
}

pub inline fn numCast(comptime T: type, value: anytype) ziggurat.sign(.seq(&.{
    .any(&.{
        .is_int(.{}),
        .is_float(.{}),
    }),
    .any(&.{
        .is_int(.{}),
        .is_float(.{}),
    }),
}))(&.{ T, @TypeOf(value) })(T) {
    return switch (@typeInfo(T)) {
        inline .int => switch (@typeInfo(@TypeOf(value))) {
            inline .int => @intCast(value),
            inline .float => @intFromFloat(value),
            else => unreachable,
        },
        inline .float => switch (@typeInfo(@TypeOf(value))) {
            inline .int => @floatFromInt(value),
            inline .float => @floatCast(value),
            else => unreachable,
        },
        else => unreachable,
    };
}

pub inline fn add(comptime T: type, a: anytype, b: anytype) T {
    return numCast(T, a) + numCast(T, b);
}

pub inline fn sub(comptime T: type, a: anytype, b: anytype) T {
    return numCast(T, a) - numCast(T, b);
}

pub inline fn mul(comptime T: type, a: anytype, b: anytype) T {
    return numCast(T, a) * numCast(T, b);
}

pub inline fn div(comptime T: type, a: anytype, b: anytype) T {
    return numCast(T, a) / numCast(T, b);
}

pub inline fn divFloor(comptime T: type, a: anytype, b: anytype) T {
    return std.math.divFloor(T, numCast(T, a), numCast(T, b));
}

pub inline fn divCeil(comptime T: type, a: anytype, b: anytype) T {
    return std.math.divCeil(T, numCast(T, a), numCast(T, b));
}

pub fn indexOf(
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(?usize) {
    for (0..len(data)) |index| {
        if (value == at(data, index)) return index;
    }
    return null;
}

pub fn lastIndexOf(
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(?usize) {
    for (1..len(data)) |i| {
        const index = len(data) - i;
        if (value == at(data, index)) return index;
    }
    return null;
}

test "at" {
    const slice: []const usize = &.{ 1, 2, 3 };

    try testing.expectEqual(1, at(slice, 0));
    try testing.expectEqual(2, at(slice, 1));
    try testing.expectEqual(3, at(slice, 2));

    const vector: @Vector(3, usize) = .{ 1, 2, 3 };

    try testing.expectEqual(1, at(&vector, 0));
    try testing.expectEqual(2, at(&vector, 1));
    try testing.expectEqual(3, at(&vector, 2));

    const array: [3]usize = .{ 1, 2, 3 };

    try testing.expectEqual(1, at(&array, 0));
    try testing.expectEqual(2, at(&array, 1));
    try testing.expectEqual(3, at(&array, 2));
}

test "len" {
    const array: [3]usize = .{ 1, 2, 3 };
    const array_pointer = try testing.allocator.create([3]usize);
    const vector: @Vector(3, usize) = .{ 1, 2, 3 };
    const vector_pointer = try testing.allocator.create(@Vector(3, usize));
    const slice = try testing.allocator.alloc(usize, 3);
    const string: [*:0]const u8 = "hello";

    try testing.expectEqual(3, len(array));
    try testing.expectEqual(3, len(array_pointer));
    try testing.expectEqual(3, len(vector));
    try testing.expectEqual(3, len(vector_pointer));
    try testing.expectEqual(3, len(slice));
    try testing.expectEqual(5, len(string));

    testing.allocator.destroy(array_pointer);
    testing.allocator.destroy(vector_pointer);
    testing.allocator.free(slice);
}

test "indexOf" {
    const array = try testing.allocator.create([3]usize);
    const vector = try testing.allocator.create(@Vector(3, usize));
    const slice: []usize = try testing.allocator.alloc(usize, 3);

    defer testing.allocator.destroy(array);
    defer testing.allocator.destroy(vector);
    defer testing.allocator.free(slice);

    array.* = .{ 2, 4, 6 };
    vector.* = .{ 2, 4, 6 };
    slice[0] = 2;
    slice[1] = 4;
    slice[2] = 6;

    try testing.expectEqual(1, indexOf(array, 4).?);
    try testing.expectEqual(1, indexOf(vector, 4).?);
    try testing.expectEqual(1, indexOf(slice, 4).?);
}

test "lastIndexOf" {
    const array = try testing.allocator.create([3]usize);
    const vector = try testing.allocator.create(@Vector(3, usize));
    const slice: []usize = try testing.allocator.alloc(usize, 3);

    defer testing.allocator.destroy(array);
    defer testing.allocator.destroy(vector);
    defer testing.allocator.free(slice);

    array.* = .{ 2, 4, 6 };
    vector.* = .{ 2, 4, 6 };
    slice[0] = 2;
    slice[1] = 4;
    slice[2] = 6;

    try testing.expectEqual(1, lastIndexOf(array, 4).?);
    try testing.expectEqual(1, lastIndexOf(vector, 4).?);
    try testing.expectEqual(1, lastIndexOf(slice, 4).?);
}
