// Copyright (c) 2026 Onyedika Nwankwo Benson
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE file in the root directory of this source tree.
const std = @import("std");
const icbinl = @import("icbnil");
const Tokenizer = icbinl.Tokenizer;

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);
    if (args.len < 2) {
        return error.NoArgs;
    }

    var file = try std.Io.Dir.cwd().openFile(init.io, args[1], .{ .mode = .read_only });
    defer file.close(init.io);

    var read_buff: [1024]u8 = undefined;
    var file_reader = file.reader(init.io, &read_buff);
    const reader = &file_reader.interface;
    var write_buff: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &write_buff);

    const data = try reader.allocRemainingAlignedSentinel(allocator, .unlimited, std.mem.Alignment.@"1", 0);

    var t = Tokenizer.init(data);

    while (true) {
        const token = t.next();
        try t.dump(&token, &stdout_writer.interface);
        if (token.tag == .eof) break;
    }
}
