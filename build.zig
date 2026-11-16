// Copyright (c) 2026 Onyedika Nwankwo Benson
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE file in the root directory of this source tree.
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("src/icbinl.zig"),
    });

    const exe_mod = b.createModule(.{
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("src/main.zig"),
    });
    exe_mod.addImport("icbnil", lib_mod);

    const exe = b.addExecutable(.{
        .name = "icbnilc",
        .root_module = exe_mod,
        .version = .{
            .major = 0,
            .minor = 0,
            .patch = 1,
            .pre = "alpha",
        },
    });
    const install = b.addInstallArtifact(exe, .{});
    const run = b.addRunArtifact(exe);
    run.addPassthruArgs();

    const run_step = b.step("run", "run the compiler");
    run_step.dependOn(&run.step);
    run_step.dependOn(&install.step);

    const tests = b.addTest(.{
        .root_module = lib_mod,
    });
    const tests_run = b.addRunArtifact(tests);

    const test_step = b.step("test", "run the tests");
    test_step.dependOn(&tests_run.step);
}
