const std = @import("std");
const testing = std.testing;
const meta = std.meta;

const ziggurat = @import("ziggurat");

const prototype = @import("prototype.zig");

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

pub fn find(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(?meta.Elem(@TypeOf(data))) {
    for (0..len(data)) |index| {
        if (func(
            at(data, index),
            index,
            data,
        )) return at(data, index);
    }

    return null;
}

pub fn findLast(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(?meta.Elem(@TypeOf(data))) {
    for (1..len(data)) |i| {
        const index = len(data) - i;
        if (func(
            at(data, index),
            index,
            data,
        )) return at(data, index);
    }
    return null;
}

pub fn findIndex(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(?usize) {
    for (0..len(data)) |index| {
        if (func(
            at(data, index),
            index,
            data,
        )) return index;
    }
    return null;
}

pub fn findLastIndex(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(?usize) {
    for (1..len(data)) |i| {
        const index = len(data) - i;
        if (func(
            at(data, index),
            index,
            data,
        )) return index;
    }
    return null;
}

pub fn reduce(
    data: anytype,
    func: *const fn (
        accumulator: meta.Elem(@TypeOf(data)),
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) meta.Elem(@TypeOf(data)) {
    var acc: meta.Elem(@TypeOf(data)) = at(data, 0);

    for (1..len(data)) |index| {
        acc = func(
            acc,
            at(data, index),
            index,
            data,
        );
    }

    return acc;
}

pub fn reduceRight(
    data: anytype,
    func: *const fn (
        accumulator: meta.Elem(@TypeOf(data)),
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) meta.Elem(@TypeOf(data)) {
    var acc: meta.Elem(@TypeOf(data)) = at(data, len(data) - 1);
    for (1..len(data) - 1) |i| {
        const index = len(data) - i;
        acc = func(
            acc,
            at(data, index),
            index,
            data,
        );
    }

    return acc;
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

test "find" {
    const array_func = struct {
        pub fn call(element: usize, _: usize, _: *const [3]usize) bool {
            return element % 4 == 0;
        }
    };

    const vector_func = struct {
        pub fn call(element: usize, _: usize, _: *const @Vector(3, usize)) bool {
            return element % 4 == 0;
        }
    };

    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []const usize) bool {
            return element % 4 == 0;
        }
    };

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

    try testing.expectEqual(4, find(array, array_func.call).?);
    try testing.expectEqual(4, find(vector, vector_func.call).?);
    try testing.expectEqual(4, find(slice, slice_func.call).?);
}

test "findLast" {
    const array_func = struct {
        pub fn call(element: usize, _: usize, _: *const [3]usize) bool {
            return element % 4 == 0;
        }
    };

    const vector_func = struct {
        pub fn call(element: usize, _: usize, _: *const @Vector(3, usize)) bool {
            return element % 4 == 0;
        }
    };

    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []const usize) bool {
            return element % 4 == 0;
        }
    };

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

    try testing.expectEqual(4, findLast(array, array_func.call).?);
    try testing.expectEqual(4, findLast(vector, vector_func.call).?);
    try testing.expectEqual(4, findLast(slice, slice_func.call).?);
}

test "findIndex" {
    const array_func = struct {
        pub fn call(element: usize, _: usize, _: *const [3]usize) bool {
            return element % 4 == 0;
        }
    };

    const vector_func = struct {
        pub fn call(element: usize, _: usize, _: *const @Vector(3, usize)) bool {
            return element % 4 == 0;
        }
    };

    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []const usize) bool {
            return element % 4 == 0;
        }
    };

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

    try testing.expectEqual(1, findIndex(array, array_func.call).?);
    try testing.expectEqual(1, findIndex(vector, vector_func.call).?);
    try testing.expectEqual(1, findIndex(slice, slice_func.call).?);
}

test "findLastIndex" {
    const array_func = struct {
        pub fn call(element: usize, _: usize, _: *const [3]usize) bool {
            return element % 4 == 0;
        }
    };

    const vector_func = struct {
        pub fn call(element: usize, _: usize, _: *const @Vector(3, usize)) bool {
            return element % 4 == 0;
        }
    };

    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []const usize) bool {
            return element % 4 == 0;
        }
    };

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

    try testing.expectEqual(1, findLastIndex(array, array_func.call).?);
    try testing.expectEqual(1, findLastIndex(vector, vector_func.call).?);
    try testing.expectEqual(1, findLastIndex(slice, slice_func.call).?);
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

test "reduce" {
    const array_func = struct {
        pub fn call(accumulator: usize, element: usize, _: usize, _: *const [3]usize) usize {
            return accumulator + element;
        }
    };

    const vector_func = struct {
        pub fn call(accumulator: usize, element: usize, _: usize, _: *const @Vector(3, usize)) usize {
            return accumulator + element;
        }
    };

    const slice_func = struct {
        pub fn call(accumulator: usize, element: usize, _: usize, _: []usize) usize {
            return accumulator + element;
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

    const array_sum = reduce(array, array_func.call);
    const vector_sum = reduce(vector, vector_func.call);
    const slice_sum = reduce(slice, slice_func.call);

    try testing.expectEqual(6, array_sum);
    try testing.expectEqual(6, vector_sum);
    try testing.expectEqual(6, slice_sum);
}

test "reduceRight" {
    const array_func = struct {
        pub fn call(accumulator: usize, element: usize, _: usize, _: *const [3]usize) usize {
            return accumulator - element;
        }
    };

    const vector_func = struct {
        pub fn call(accumulator: usize, element: usize, _: usize, _: *const @Vector(3, usize)) usize {
            return accumulator - element;
        }
    };

    const slice_func = struct {
        pub fn call(accumulator: usize, element: usize, _: usize, _: []usize) usize {
            return accumulator - element;
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

    const array_sum = reduceRight(array, array_func.call);
    const vector_sum = reduceRight(vector, vector_func.call);
    const slice_sum = reduceRight(slice, slice_func.call);

    try testing.expectEqual(0, array_sum);
    try testing.expectEqual(0, vector_sum);
    try testing.expectEqual(0, slice_sum);
}
