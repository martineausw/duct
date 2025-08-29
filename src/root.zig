const std = @import("std");
const meta = std.meta;
const testing = std.testing;
const Allocator = std.mem.Allocator;

const ziggurat = @import("ziggurat");

pub const has_index: ziggurat.Prototype = .any(&.{
    .is_array(.{}),
    .is_vector(.{}),
    .is_pointer(.{
        .child = .any(&.{
            .is_array(.{}),
            .is_vector(.{}),
        }),
    }),
    .is_pointer(.{ .size = .{
        .slice = true,
        .many = true,
    } }),
});

pub inline fn at(
    data: anytype,
    index: usize,
) ziggurat.sign(has_index)(@TypeOf(data))(meta.Elem(@TypeOf(data))) {
    return data[index];
}

pub inline fn set(
    data: anytype,
    index: usize,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(.all(&.{
    has_index,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    data[index] = value;
}

pub const has_known_len: ziggurat.Prototype = .any(&.{
    .is_array(.{}),
    .is_vector(.{}),
    .is_pointer(.{ .child = .any(&.{
        .is_array(.{}),
        .is_vector(.{}),
    }), .size = .{ .one = true } }),
    .is_pointer(.{ .size = .{ .slice = true } }),
    .is_pointer(.{ .size = .{
        .many = true,
        .c = true,
    }, .sentinel = true }),
});

pub inline fn len(
    data: anytype,
) ziggurat.sign(has_known_len)(@TypeOf(data))(usize) {
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

pub fn forEach(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        array: @TypeOf(data),
    ) void,
) ziggurat.sign(has_known_len)(@TypeOf(data))(void) {
    for (0..len(data)) |index| {
        func(
            at(data, index),
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
) ziggurat.sign(has_known_len)(@TypeOf(data))(bool) {
    var result: bool = true;
    for (0..len(data)) |index| {
        result = result and func(
            at(data, index),
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
) ziggurat.sign(has_known_len)(@TypeOf(data))(bool) {
    for (0..len(data)) |index| {
        if (func(
            at(data, index),
            index,
            data,
        )) return true;
    }
    return false;
}

pub fn find(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(has_known_len)(@TypeOf(data))(?meta.Elem(@TypeOf(data))) {
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
) ziggurat.sign(has_known_len)(@TypeOf(data))(?meta.Elem(@TypeOf(data))) {
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
) ziggurat.sign(has_known_len)(@TypeOf(data))(?usize) {
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
) ziggurat.sign(has_known_len)(@TypeOf(data))(?usize) {
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

pub fn indexOf(
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(has_known_len)(@TypeOf(data))(?usize) {
    for (0..len(data)) |index| {
        if (value == at(data, index)) return index;
    }
    return null;
}

pub fn lastIndexOf(
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(has_known_len)(@TypeOf(data))(?usize) {
    for (1..len(data)) |i| {
        const index = len(data) - i;
        if (value == at(data, index)) return index;
    }
    return null;
}

pub fn mapToSlice(
    allocator: Allocator,
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) ziggurat.sign(has_known_len)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), len(data));

    for (0..len(data)) |index| {
        result[index] = func(
            at(data, index),
            index,
            data,
        );
    }

    return result;
}

pub fn filterToSlice(
    allocator: Allocator,
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) bool,
) ziggurat.sign(has_known_len)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const curr_len = len(data);

    var new_len: usize = 0;
    for (0..curr_len) |index| {
        if (func(
            at(data, index),
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
            at(data, index),
            index,
            data,
        )) {
            result[result_index] = data[index];
            result_index += 1;
        }
    }

    return result;
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

pub fn mapInPlace(
    data: anytype,
    func: *const fn (
        element: meta.Elem(@TypeOf(data)),
        index: usize,
        data: @TypeOf(data),
    ) meta.Elem(@TypeOf(data)),
) ziggurat.sign(.all(&.{
    has_known_len,
    .not(.is_array(.{})),
    .not(.is_pointer(.{})),
}))(@TypeOf(data))(void) {
    for (0..len(data)) |index| {
        set(
            data,
            index,
            func(at(data, index), index, data),
        );
    }
}

pub fn fillInPlace(
    data: anytype,
    value: meta.Elem(@TypeOf(data)),
) ziggurat.sign(.all(&.{
    has_known_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    for (0..len(data)) |index| {
        set(data, index, value);
    }
}

pub fn onesInPlace(
    data: anytype,
) ziggurat.sign(.all(&.{
    has_known_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    fillInPlace(data, 1);
}

pub fn zeroesInPlace(
    data: anytype,
) ziggurat.sign(.all(&.{
    has_known_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    fillInPlace(data, 0);
}

pub fn transposeInPlace(
    allocator: Allocator,
    data: anytype,
    axes: []const usize,
) ziggurat.sign(.any(&.{
    has_known_len,
    .not(.is_array(.{})),
    .not(.is_vector(.{})),
}))(@TypeOf(data))(void) {
    if (len(data) != axes.len) return error.MismatchedLengths;

    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), len(data));

    for (0..len) |index| {
        result[index] = at(data, axes[index]);
    }

    for (0..data) |index| {
        set(data, index, result[index]);
    }

    allocator.free(result);
}

pub fn copyToSlice(
    allocator: Allocator,
    data: anytype,
) ziggurat.sign(has_known_len)(@TypeOf(data))(Allocator.Error![]meta.Elem(@TypeOf(data))) {
    const result = try allocator.alloc(meta.Elem(@TypeOf(data)), len(data));

    for (0..result.len) |index| {
        result = at(data, index);
    }

    return result;
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

test "set" {
    @setEvalBranchQuota(2000);
    const slice: []usize = try testing.allocator.alloc(usize, 3);
    defer testing.allocator.free(slice);

    set(slice, 0, 2);
    set(slice, 1, 4);
    set(slice, 2, 6);

    try testing.expectEqual(2, slice[0]);
    try testing.expectEqual(4, slice[1]);
    try testing.expectEqual(6, slice[2]);

    var vector: @Vector(3, usize) = .{ 1, 2, 3 };
    vector[0] = 1;

    set(&vector, 0, 2);
    set(&vector, 1, 4);
    set(&vector, 2, 6);

    try testing.expectEqual(2, vector[0]);
    try testing.expectEqual(4, vector[1]);
    try testing.expectEqual(6, vector[2]);

    var array: [3]usize = .{ 1, 2, 3 };
    array[0] = 1;

    set(&array, 0, 2);
    set(&array, 1, 4);
    set(&array, 2, 6);

    try testing.expectEqual(2, array[0]);
    try testing.expectEqual(4, array[1]);
    try testing.expectEqual(6, array[2]);
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

    const array_doubled = try mapToSlice(testing.allocator, array, array_func.call);
    defer testing.allocator.free(array_doubled);
    const vector_doubled = try mapToSlice(testing.allocator, vector, vector_func.call);
    defer testing.allocator.free(vector_doubled);
    const slice_doubled = try mapToSlice(testing.allocator, slice, slice_func.call);
    defer testing.allocator.free(slice_doubled);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, array_doubled);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, vector_doubled);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice_doubled);
}

test "mapInPlace" {
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

    mapInPlace(array, array_func.call);
    mapInPlace(vector, vector_func.call);
    mapInPlace(slice, slice_func.call);

    try testing.expectEqualDeep([_]usize{ 2, 4, 6 }, array.*);
    try testing.expectEqualDeep(@Vector(3, usize){ 2, 4, 6 }, vector.*);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice);
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

    const array_doubled = try filterToSlice(testing.allocator, array, array_func.call);
    defer testing.allocator.free(array_doubled);
    const vector_doubled = try filterToSlice(testing.allocator, vector, vector_func.call);
    defer testing.allocator.free(vector_doubled);
    const slice_doubled = try filterToSlice(testing.allocator, slice, slice_func.call);
    defer testing.allocator.free(slice_doubled);

    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, array_doubled);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, vector_doubled);
    try testing.expectEqualSlices(usize, &.{ 2, 4, 6 }, slice_doubled);
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
