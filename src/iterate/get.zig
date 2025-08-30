const std = @import("std");
const testing = std.testing;
const meta = std.meta;

const ziggurat = @import("ziggurat");
const prototype = @import("../prototype.zig");

const get = @import("../get.zig");
const set = @import("../set.zig");

pub fn find(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(?meta.Elem(@TypeOf(data))) {
    for (0..get.len(data)) |index| {
        if (func(
            get.at(data, index),
            index,
            data,
        )) return get.at(data, index);
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
    for (1..get.len(data) + 1) |i| {
        const index = get.len(data) - i;
        if (func(
            get.at(data, index),
            index,
            data,
        )) return get.at(data, index);
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
    for (0..get.len(data)) |index| {
        if (func(
            get.at(data, index),
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
    for (1..get.len(data) + 1) |i| {
        const index = get.len(data) - i;
        if (func(
            get.at(data, index),
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
    var acc: meta.Elem(@TypeOf(data)) = get.at(data, 0);

    for (1..get.len(data)) |index| {
        acc = func(
            acc,
            get.at(data, index),
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
    var acc: meta.Elem(@TypeOf(data)) = get.at(data, get.len(data) - 1);
    for (2..get.len(data) + 1) |i| {
        const index = get.len(data) - i;
        acc = func(
            acc,
            get.at(data, index),
            index,
            data,
        );
    }

    return acc;
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
