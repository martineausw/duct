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
    allocator: Allocator,
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), get.len(data));

    for (0..get.len(data)) |index| {
        result[index] = func(
            get.at(data, index),
            index,
            data,
        );
    }

    return result;
}

pub fn mapWith(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
    func: *const fn (
        elements: struct { meta.Elem(@TypeOf(a)), meta.Elem(@TypeOf(b)) },
        index: usize,
        data: struct { @TypeOf(a), @TypeOf(b) },
    ) T,
) ziggurat.sign(.seq(&.{
    prototype.has_len,
    prototype.has_len,
}))(.{
    @TypeOf(a),
    @TypeOf(b),
})(Allocator.Error![]T) {
    const result = try allocator.alloc(T, get.len(a));

    for (0..result.len) |index| {
        result[index] = func(
            .{ get.at(a, index), get.at(b, index) },
            index,
            .{ a, b },
        );
    }

    return result;
}

pub fn add(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return mapWith(
        allocator,
        T,
        a,
        b,
        ElementMath(T, @TypeOf(a), @TypeOf(b)).add,
    );
}

pub fn sub(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return mapWith(
        allocator,
        T,
        a,
        b,
        ElementMath(T, @TypeOf(a), @TypeOf(b)).sub,
    );
}

pub fn mul(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return mapWith(
        allocator,
        T,
        a,
        b,
        ElementMath(T, @TypeOf(a), @TypeOf(b)).mul,
    );
}

pub fn div(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return mapWith(
        allocator,
        T,
        a,
        b,
        ElementMath(T, @TypeOf(a), @TypeOf(b)).div,
    );
}

pub fn divFloor(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return mapWith(
        allocator,
        T,
        a,
        b,
        ElementMath(T, @TypeOf(a), @TypeOf(b)).divFloor,
    );
}

pub fn divCeil(
    allocator: Allocator,
    comptime T: type,
    a: anytype,
    b: anytype,
) Allocator.Error![]T {
    return mapWith(
        allocator,
        T,
        a,
        b,
        ElementMath(T, @TypeOf(a), @TypeOf(b)).divCeil,
    );
}

pub fn mapRight(
    allocator: Allocator,
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), get.len(data));

    for (1..get.len(data) + 1) |i| {
        const index = get.len(data) - i;
        result[index] = func(
            get.at(data, index),
            index,
            data,
        );
    }

    return result;
}

pub fn filter(
    allocator: Allocator,
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(
    prototype.has_len,
)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const curr_len = get.len(data);

    var new_len: usize = 0;
    for (0..curr_len) |index| {
        if (func(
            get.at(data, index),
            index,
            data,
        )) {
            new_len += 1;
        }
    }

    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), new_len);

    var result_index: usize = 0;
    for (0..curr_len) |index| {
        if (func(
            get.at(data, index),
            index,
            data,
        )) {
            result[result_index] = data[index];
            result_index += 1;
        }
    }

    return result;
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

    const array_doubled = try map(testing.allocator, array, array_func.call);
    defer testing.allocator.free(array_doubled);
    const vector_doubled = try map(testing.allocator, vector, vector_func.call);
    defer testing.allocator.free(vector_doubled);
    const slice_doubled = try map(testing.allocator, slice, slice_func.call);
    defer testing.allocator.free(slice_doubled);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, array_doubled);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, vector_doubled);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice_doubled);
}

test "filter" {
    const array_func = struct {
        pub fn call(element: usize, _: usize, _: *const [6]usize) bool {
            return element % 2 == 0;
        }
    };

    const vector_func = struct {
        pub fn call(element: usize, _: usize, _: *const @Vector(6, usize)) bool {
            return element % 2 == 0;
        }
    };

    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []usize) bool {
            return element % 2 == 0;
        }
    };

    const array = try testing.allocator.create([6]usize);
    const vector = try testing.allocator.create(@Vector(6, usize));
    const slice: []usize = try testing.allocator.alloc(usize, 6);

    defer testing.allocator.destroy(array);
    defer testing.allocator.destroy(vector);
    defer testing.allocator.free(slice);

    array.* = .{ 1, 2, 3, 4, 5, 6 };
    vector.* = .{ 1, 2, 3, 4, 5, 6 };
    slice[0] = 1;
    slice[1] = 2;
    slice[2] = 3;
    slice[3] = 4;
    slice[4] = 5;
    slice[5] = 6;

    const array_doubled = try filter(testing.allocator, array, array_func.call);
    defer testing.allocator.free(array_doubled);
    const vector_doubled = try filter(testing.allocator, vector, vector_func.call);
    defer testing.allocator.free(vector_doubled);
    const slice_doubled = try filter(testing.allocator, slice, slice_func.call);
    defer testing.allocator.free(slice_doubled);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, array_doubled);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, vector_doubled);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice_doubled);
}
