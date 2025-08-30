const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const mod = b.addModule("duct", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const ziggurat = b.dependency("ziggurat", .{
        .target = target,
    });

    mod.addImport("ziggurat", ziggurat.module("ziggurat"));

    const mod_tests = b.addTest(.{
        .root_module = mod,
        .name = "duct tests",
    });

    const ziggurat_tests = b.addTest(.{
        .root_module = ziggurat.module("ziggurat"),
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);
    const run_ziggurat_tests = b.addRunArtifact(ziggurat_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_ziggurat_tests.step);
}
