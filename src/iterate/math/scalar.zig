pub const new = @import("scalar/new.zig");
pub const set = @import("scalar/set.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
