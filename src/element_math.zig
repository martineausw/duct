const meta = @import("std").meta;
const get = @import("get.zig");

pub fn ElementMath(comptime T: type, comptime A: type, comptime B: type) type {
    return struct {
        pub fn add(
            elements: struct { meta.Elem(A), meta.Elem(B) },
            _: usize,
            _: struct { A, B },
        ) T {
            return get.add(T, elements.@"0", elements.@"1");
        }

        pub fn sub(
            elements: struct { meta.Elem(A), meta.Elem(B) },
            _: usize,
            _: struct { A, B },
        ) T {
            return get.sub(T, elements.@"0", elements.@"1");
        }

        pub fn mul(
            elements: struct { meta.Elem(A), meta.Elem(B) },
            _: usize,
            _: struct { A, B },
        ) T {
            return get.mul(T, elements.@"0", elements.@"1");
        }

        pub fn div(
            elements: struct { meta.Elem(A), meta.Elem(B) },
            _: usize,
            _: struct { A, B },
        ) T {
            return get.div(T, elements.@"0", elements.@"1");
        }

        pub fn divFloor(
            elements: struct { meta.Elem(A), meta.Elem(B) },
            _: usize,
            _: struct { A, B },
        ) T {
            return get.divFloor(T, elements.@"0", elements.@"1");
        }

        pub fn divCeil(
            elements: struct { meta.Elem(A), meta.Elem(B) },
            _: usize,
            _: struct { A, B },
        ) T {
            return get.divCeil(T, elements.@"0", elements.@"1");
        }
    };
}
