pub const new = @import("scl/new.zig");
pub const set = @import("scl/set.zig");

test {
    @import("std").testing.refAllDecls(@This());
}

const ops = @import("../../ops.zig");
const meta = @import("std").meta;
const ziggurat = @import("ziggurat");
const prototype = @import("../../prototype.zig");

pub fn Scalar(
    comptime T: type,
    comptime Data: type,
) ziggurat.sign(.seq(&.{
    prototype.is_number,
    prototype.are_numbers,
}))(.{ T, Data })(type) {
    return struct {
        pub fn add(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return ops.add(T, element, scalar);
        }

        pub fn sub(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return ops.sub(T, element, scalar);
        }

        pub fn mul(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return ops.mul(T, element, scalar);
        }

        pub fn div(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return ops.div(T, element, scalar);
        }

        pub fn divFloor(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return ops.divFloor(T, element, scalar);
        }

        pub fn divCeil(
            scalar: T,
            element: meta.Elem(Data),
            _: usize,
            _: Data,
        ) T {
            return ops.divCeil(T, element, scalar);
        }
    };
}
