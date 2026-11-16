// Copyright (c) 2026 Onyedika Nwankwo Benson
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE file in the root directory of this source tree.

const std = @import("std");
const Token = @import("tokenizer.zig").Token;
const Ast = @This();
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

source: [:0]const u8,
extra_data: []u32,
tokens: TokenList.Slice,
node: NodeList.Slice,

pub const ByteOffset = u32;
pub const TokenList = std.MultiArrayList(struct {
    tag: Token.Tag,
    start: ByteOffset,
});

pub const NodeList = std.MultiArrayList(Node);
pub const ExtraIndex = enum(u32) {
    _,
};

pub fn extraDataSlice(tree: Ast, range: Node.SubRange, comptime T: type) []const T {
    return @ptrCast(tree.extra_data[@backingInt(range.start)..@backingInt(range.end)]);
}

pub fn extraDataSliceWithLen(tree: Ast, start: ExtraIndex, len: u32, comptime T: type) []const T {
    return @ptrCast(tree.extra_data[@backingInt(start)..][0..len]);
}

pub fn extraData(tree: Ast, index: ExtraIndex, comptime T: type) T {
    const info = @typeInfo(T).@"struct";
    var result: T = undefined;
    inline for (info.field_names, info.field_types, 0..) |field_name, field_type, i| {
        @field(result, field_name) = switch (field_type) {
            Node.Index,
            Node.OptionalIndex,
            OptionalTokenIndex,
            ExtraIndex,
            => @fromBackingInt(@intCast(tree.extra_data[@backingInt(index) + i])),
            TokenIndex => tree.extra_data[@backingInt(index) + i],
            else => @compileError("unexpected field type: " ++ @typeName(field_type)),
        };
    }
    return result;
}

pub const TokenIndex = u32;
pub const OptionalTokenIndex = enum(u32) {
    none = std.math.maxInt(u32),
    _,

    pub fn unwrap(oti: OptionalTokenIndex) ?TokenIndex {
        return if (oti == .none) null else @backingInt(oti);
    }

    pub fn fromToken(ti: TokenIndex) OptionalTokenIndex {
        return @fromBackingInt(@intCast(ti));
    }

    pub fn fromOptional(oti: ?TokenIndex) OptionalTokenIndex {
        return if (oti) |ti| @fromBackingInt(@intCast(ti)) else .none;
    }
};

pub const Node = struct {
    tag: Tag,
    main_token: TokenIndex,
    data: Data,

    pub const Index = enum(u32) {
        root = 0,
        _,

        pub fn toOptional(i: Index) OptionalIndex {
            const result: OptionalIndex = @fromBackingInt(@intCast(@backingInt(i)));
            assert(result != .none);
            return result;
        }
    };
    pub const OptionalIndex = enum(u32) {
        root = 0,
        none = std.math.maxInt(u32),
        _,
        pub fn unwrap(oi: OptionalIndex) ?Index {
            return if (oi == .none) null else @fromBackingInt(@intCast(@backingInt(oi)));
        }

        pub fn fromOptional(oi: ?Index) OptionalIndex {
            return if (oi) |i| i.toOptional() else .none;
        }
    };
    pub const Tag = enum {
        root,
        module_decl,
        require_stmt,

        // Type Definitions
        record_def,
        interface_def,
        enum_def,
        error_def,
        union_def,
        distinct_type_def,

        // Variables and Constants
        var_decl,
        const_decl,

        //Functions
        function_def,
        export_def,
        extern_def,
        // Control flow
        if_stmt,
        while_stmt,
        for_stmt,
        switch_stmt,
        return_stmt,
        defer_stmt,
        comptime_block,

        assign,
        assign_destructre,
        plus,
        assign_plus,
        minus,
        assign_minus,
        mul,
        assign_mul,
        div,
        assign_div,
        bitshift_right,
        assign_bitshift_right,
        bitshift_left,
        assign_bitshift_left,
        less_than,
        less_than_equal,
        greater_than,
        greater_than_equal,
        not_equal,
        equal_equal,
        logical_or,
        logical_and,
        logical_not,
        bitwise_or,
        bitwise_not,
        bitwise_and,
        assign_bitwise_or,
        assign_bitwise_not,
        assign_bitwise_and,
        negation,
        array_type,
        array_type_sentinel,
        array_access,
        array_init,
        record_init,
        ptr_type,
        slice_open,
        slice,
        deref,
        call,
    };
    pub const Data = union {};
};
