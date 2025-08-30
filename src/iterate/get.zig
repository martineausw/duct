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
    for (2..get.len(data)) |i| {
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
