const std = @import("std");
const testing = std.testing;
const meta = std.meta;

const ziggurat = @import("ziggurat");

const element_get = @import("get.zig");
const prototype = @import("prototype.zig");

pub const get = @import("iterate/get.zig");
pub const set = @import("iterate/set.zig");
pub const new = @import("iterate/new.zig");

pub fn forEach(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        array: @TypeOf(data),
    ) void,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(void) {
    for (0..element_get.len(data)) |index| {
        func(
            element_get.at(data, index),
            index,
            data,
        );
    }
}

pub fn every(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(bool) {
    var result: bool = true;
    for (0..element_get.len(data)) |index| {
        result = result and func(
            element_get.at(data, index),
            index,
            data,
        );
    }
    return result;
}

pub fn some(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(prototype.has_len)(@TypeOf(data))(bool) {
    for (0..element_get.len(data)) |index| {
        if (func(
            element_get.at(data, index),
            index,
            data,
        )) return true;
    }
    return false;
}

test "every" {
    const array_func = struct {
        pub fn call(element: usize, _: usize, _: *const [3]usize) bool {
            return element % 2 == 0;
        }
    };

    const vector_func = struct {
        pub fn call(element: usize, _: usize, _: *const @Vector(3, usize)) bool {
            return element % 2 == 0;
        }
    };

    const slice_func = struct {
        pub fn call(element: usize, _: usize, _: []const usize) bool {
            return element % 2 == 0;
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

    try testing.expectEqual(true, every(array, array_func.call));
    try testing.expectEqual(true, every(vector, vector_func.call));
    try testing.expectEqual(true, every(slice, slice_func.call));
}

test "some" {
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

    try testing.expectEqual(true, some(array, array_func.call));
    try testing.expectEqual(true, some(vector, vector_func.call));
    try testing.expectEqual(true, some(slice, slice_func.call));
}

test "forEach" {
    const array_func = struct {
        pub var captured = [3]usize{ 0, 0, 0 };
        pub fn call(element: usize, index: usize, _: *const [3]usize) void {
            captured[index] = element;
        }
    };

    const vector_func = struct {
        pub var captured = [3]usize{ 0, 0, 0 };
        pub fn call(element: usize, index: usize, _: *const @Vector(3, usize)) void {
            captured[index] = element;
        }
    };

    const slice_func = struct {
        pub var captured = [3]usize{ 0, 0, 0 };
        pub fn call(element: usize, index: usize, _: []const usize) void {
            captured[index] = element;
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

    forEach(array, array_func.call);
    forEach(vector, vector_func.call);
    forEach(slice, slice_func.call);

    try testing.expectEqualDeep([3]usize{ 1, 2, 3 }, array_func.captured);
    try testing.expectEqualDeep([3]usize{ 1, 2, 3 }, vector_func.captured);
    try testing.expectEqualDeep([3]usize{ 1, 2, 3 }, slice_func.captured);
}
