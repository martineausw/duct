const std = @import("std");
const testing = std.testing;
const meta = std.meta;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");
const prototype = @import("../prototype.zig");

const get = @import("../get.zig");
const set = @import("../set.zig");

const ElementMath = @import("../element_math.zig").ElementMath;

pub fn map(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) ziggurat.sign(.all(&.{
    prototype.has_len,
    .not(.is_array(.{})),
    .not(.is_pointer(.{})),
}))(@TypeOf(data))(void) {
    for (0..get.len(data)) |index| {
        set.set(
            data,
            index,
            func(get.at(data, index), index, data),
        );
    }
}

pub fn mapWith(
    comptime T: type,
    dest: anytype,
    aux: anytype,
    func: *const fn (
        elements: struct { meta.Elem(@TypeOf(dest)), meta.Elem(@TypeOf(aux)) },
        index: usize,
        data: struct { @TypeOf(dest), @TypeOf(aux) },
    ) T,
) ziggurat.sign(.seq(&.{
    prototype.has_len,
    prototype.has_len,
}))(.{
    @TypeOf(dest),
    @TypeOf(aux),
})(void) {
    for (0..dest.len) |index| {
        set.set(index, func(
            .{ get.at(dest, index), get.at(aux, index) },
            index,
            .{ dest, aux },
        ));
    }
}

pub fn add(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return mapWith(
        T,
        dest,
        aux,
        ElementMath(T, @TypeOf(dest), @TypeOf(aux)).add,
    );
}

pub fn sub(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return mapWith(
        T,
        dest,
        aux,
        ElementMath(T, @TypeOf(dest), @TypeOf(aux)).sub,
    );
}

pub fn mul(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return mapWith(
        T,
        dest,
        aux,
        ElementMath(T, @TypeOf(dest), @TypeOf(aux)).mul,
    );
}

pub fn div(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return mapWith(
        T,
        dest,
        aux,
        ElementMath(T, @TypeOf(dest), @TypeOf(aux)).div,
    );
}

pub fn divFloor(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return mapWith(
        T,
        dest,
        aux,
        ElementMath(T, @TypeOf(dest), @TypeOf(aux)).divFloor,
    );
}

pub fn divCeil(
    comptime T: type,
    dest: anytype,
    aux: anytype,
) void {
    return mapWith(
        T,
        dest,
        aux,
        ElementMath(T, @TypeOf(dest), @TypeOf(aux)).divCeil,
    );
}

pub fn filter(
    allocator: Allocator,
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data.*)),
        index: usize,
        data: (@TypeOf(data.*)),
    ) bool,
) ziggurat.sign(.is_pointer(.{
    .child = prototype.is_slice,
    .is_const = false,
    .size = .{ .one = true },
}))(@TypeOf(data))(Allocator.Error!void) {
    const curr_len = get.len(data.*);

    var new_len: usize = 0;
    for (0..curr_len) |index| {
        if (func(
            get.at(data.*, index),
            index,
            data.*,
        )) {
            new_len += 1;
        }
    }

    const result = try allocator.alloc(meta.Elem(@TypeOf(data.*)), new_len);

    var result_index: usize = 0;
    for (0..curr_len) |index| {
        if (func(
            get.at(data.*, index),
            index,
            data.*,
        )) {
            result[result_index] = get.at(data.*, index);
            result_index += 1;
        }
    }

    allocator.free(data.*);
    data.* = result;
}

test "map" {
    const array_func = struct {
        pub fn call(element: usize, _: usize, _: *[3]usize) usize {
            return element * 2;
        }
    };

    const vector_func = struct {
        pub fn call(element: usize, _: usize, _: *@Vector(3, usize)) usize {
            return element * 2;
        }
    };

    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []usize) usize {
            return element * 2;
        }
    };

    const array = try testing.allocator.create([3]usize);
    const vector = try testing.allocator.create(@Vector(3, usize));
    const slice: []usize = try testing.allocator.alloc(usize, 3);

    defer testing.allocator.destroy(array);
    defer testing.allocator.destroy(vector);
    defer testing.allocator.free(slice);

    array.* = .{ 1, 2, 3 };
    vector.* = .{ 1, 2, 3 };
    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;

    map(array, array_func.call);
    map(vector, vector_func.call);
    map(slice, slice_func.call);

    try testing.expectEqualDeep([_]usize{ 2, 4, 6 }, array.*);
    try testing.expectEqualDeep(@Vector(3, usize){ 2, 4, 6 }, vector.*);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
}

test "filter" {
    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []usize) bool {
            return element % 2 == 0;
        }
    };

    var slice: []usize = try testing.allocator.alloc(usize, 6);
    defer testing.allocator.free(slice);

    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;
    slice[3] = 4;
    slice[4] = 5;
    slice[5] = 6;

    try filter(testing.allocator, &slice, slice_func.call);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
}
