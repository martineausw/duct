pub const new = @import("scl/new.zig").new;
pub const set = @import("scl/set.zig").set;

test {
    @import("std").testing.refAllDecls(@This());
}

const ops = @import("../../ops.zig");
const meta = @import("std").meta;
const ziggurat = @import("ziggurat");
const prototype = @import("../../prototype.zig");
