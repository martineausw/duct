pub const element = @import("ops/elm.zig");
pub const scalar = @import("ops/scl.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
