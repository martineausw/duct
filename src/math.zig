const meta = @import("std").meta;

const ziggurat = @import("ziggurat");

const get = @import("get.zig");
const prototype = @import("prototype.zig");

const are_numbers: ziggurat.Prototype = .any(&.{
    .is_array(.{ .child = prototype.is_number }),
    .is_vector(.{ .child = prototype.is_number }),
    .is_pointer(.{
        .child = prototype.is_number,
        .size = .{ .slice = true },
    }),
    .is_pointer(.{ .child = prototype.is_number, .size = .{ .many = true }, .sentinel = true }),
});

pub fn Scalar(
    comptime T: type,
    comptime Data: type,
) ziggurat.sign(.seq(&.{
    prototype.is_number,
    are_numbers,
}))(.{ T, Data })(type) {
    return struct {
        pub fn add(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return get.add(T, element, scalar);
        }

        pub fn sub(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return get.sub(T, element, scalar);
        }

        pub fn mul(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return get.mul(T, element, scalar);
        }

        pub fn div(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return get.div(T, element, scalar);
        }

        pub fn divFloor(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return get.divFloor(T, element, scalar);
        }

        pub fn divCeil(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return get.divCeil(T, element, scalar);
        }
    };
}

pub fn Element(
    comptime T: type,
    comptime Data0: type,
    comptime Data1: type,
) ziggurat.sign(.seq(&.{
    prototype.is_number,
    are_numbers,
    are_numbers,
}))(.{ T, Data0, Data1 })(type) {
    return struct {
        pub fn add(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return get.add(T, elements.@"0", elements.@"1");
        }

        pub fn sub(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return get.sub(T, elements.@"0", elements.@"1");
        }

        pub fn mul(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return get.mul(T, elements.@"0", elements.@"1");
        }

        pub fn div(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return get.div(T, elements.@"0", elements.@"1");
        }

        pub fn divFloor(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return get.divFloor(T, elements.@"0", elements.@"1");
        }

        pub fn divCeil(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return get.divCeil(T, elements.@"0", elements.@"1");
        }
    };
}
