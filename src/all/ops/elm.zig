pub const new = @import("elm/new.zig");
pub const set = @import("elm/set.zig");

test {
    @import("std").testing.refAllDecls(@This());
}

const ops = @import("../../ops.zig");
const meta = @import("std").meta;
const ziggurat = @import("ziggurat");
const prototype = @import("../../prototype.zig");

pub fn Element(
    comptime T: type,
    comptime Data0: type,
    comptime Data1: type,
) ziggurat.sign(.seq(&.{
    prototype.is_number,
    prototype.are_numbers,
    prototype.are_numbers,
}))(.{ T, Data0, Data1 })(type) {
    return struct {
        pub fn add(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return ops.add(T, elements.@"0", elements.@"1");
        }

        pub fn sub(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return ops.sub(T, elements.@"0", elements.@"1");
        }

        pub fn mul(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return ops.mul(T, elements.@"0", elements.@"1");
        }

        pub fn div(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return ops.div(T, elements.@"0", elements.@"1");
        }

        pub fn divFloor(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return ops.divFloor(T, elements.@"0", elements.@"1");
        }

        pub fn divCeil(
            elements: struct { meta.Elem(Data0), meta.Elem(Data1) },
            _: usize,
            _: struct { Data0, Data1 },
        ) T {
            return ops.divCeil(T, elements.@"0", elements.@"1");
        }
    };
}
