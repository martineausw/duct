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

pub const has_len: ziggurat.Prototype = .any(&.{
    .is_array(.{}),
    .is_vector(.{}),
    .is_pointer(.{ .child = .any(&.{
        .is_array(.{}),
        .is_vector(.{}),
    }), .size = .{ .one = true } }),
    .is_pointer(.{ .size = .{ .slice = true } }),
    .is_pointer(.{ .size = .{
        .many = true,
    }, .sentinel = true }),
});

pub const is_slice: ziggurat.Prototype = .any(&.{
    .is_pointer(.{ .size = .{ .slice = true } }),
});

pub const is_number: ziggurat.Prototype = .any(&.{
    .is_int(.{}),
    .is_float(.{}),
});

pub const are_numbers: ziggurat.Prototype = .any(&.{
    .is_array(.{ .child = is_number }),
    .is_vector(.{ .child = is_number }),
    .is_pointer(.{
        .child = is_number,
        .size = .{ .slice = true },
    }),
    .is_pointer(.{ .child = is_number, .size = .{ .many = true }, .sentinel = true }),
});

pub const has_index_mutable: ziggurat.Prototype = .any(&.{
    is_slice,
    .is_pointer(.{
        .child = has_index,
        .size = .{ .one = true },
        .is_const = false,
    }),
});

pub const has_dynamic_len_mutable: ziggurat.Prototype = .any(&.{
    is_slice,
    .is_pointer(.{
        .child = is_slice,
        .size = .{ .one = true },
        .is_const = false,
    }),
});

pub const has_len_mutable: ziggurat.Prototype = .any(&.{
    is_slice,
    .is_pointer(.{
        .child = has_len,
        .size = .{ .one = true },
        .is_const = false,
    }),
});
