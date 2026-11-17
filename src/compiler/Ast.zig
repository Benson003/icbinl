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

        field_acesss,
        unwrap_optional,
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
        slice_open,
        slice,
        deref,
        call,
        container_decl,
        container_decl_arg,
        block,
        ptr_type,
        ptr_type_senitnel,
    };
    pub const Data = union {
        node: Index,
        opt_node: OptionalIndex,
        token_index: TokenIndex,
        node_and_node: struct { Index, Index },
        opt_node_and_opt_node: struct { OptionalIndex, OptionalIndex },
        node_and_opt_node: struct { Index, OptionalIndex },
        opt_node_and_node: struct { OptionalIndex, Index },
        node_and_extra: struct { Index, ExtraIndex },
        extra_and_node: struct { ExtraIndex, Index },
        extra_and_opt_node: struct { ExtraIndex, OptionalIndex },
        node_and_token: struct { Index, TokenIndex },
        token_and_node: struct { TokenIndex, Index },
        token_and_token: struct { TokenIndex, TokenIndex },
        opt_node_and_token: struct { OptionalIndex, TokenIndex },
        opt_token_and_node: struct { OptionalTokenIndex, Index },
        opt_token_and_opt_node: struct { OptionalTokenIndex, OptionalIndex },
        opt_token_and_opt_token: struct { OptionalTokenIndex, OptionalTokenIndex },
        extra_range: SubRange,
    };

    pub const SubRange = struct {
        /// Index into extra_data.
        start: ExtraIndex,
        /// Index into extra_data.
        end: ExtraIndex,
    };
};

pub const full = struct {
    pub const Module = struct {
        mod_token: TokenIndex,
        name: TokenIndex,
    };

    pub const Require = struct {
        mod_token: TokenIndex,
        name: TokenIndex,
    };

    pub const TypeDef = struct {
        type: TokenIndex,
        identfier: TokenIndex,
        strong: bool,
    };

    pub const ContainerField = struct {
        comptime_token: ?TokenIndex,
        ast: Components,
        pub const Components = struct {
            main_token: TokenIndex,
            type_expr: Node.OptionalIndex,
            align_expr: Node.OptionalIndex,
            value_expr: Node.OptionalIndex,
        };
        pub fn firstToken(cf: ContainerField) TokenIndex {
            return cf.comptime_token orelse cf.ast.main_token;
        }
    };

    pub const ContainerDecl = struct {
        packed_token: ?TokenIndex,
        align_node: ?Node.Index,
        ast: Components,
        pub const Components = struct {
            main_token: TokenIndex,
            members: []const Node.Index,
            arg: Node.OptionalIndex,
        };
    };

    pub const VarDecl = struct {
        visib_token: ?TokenIndex,
        extern_export_token: ?TokenIndex,
        comptime_token: ?TokenIndex,
        ast: Components,
        pub const Components = struct {
            mut_token: TokenIndex,
            type_node: Node.OptionalIndex,
            align_node: Node.OptionalIndex,
            addrspace_node: Node.OptionalIndex,
            section_node: Node.OptionalIndex,
            init_node: Node.OptionalIndex,
        };
        pub fn firstToken(var_decl: VarDecl) TokenIndex {
            return var_decl.visib_token orelse
                var_decl.extern_export_token orelse
                var_decl.comptime_token orelse
                var_decl.ast.mut_token;
        }
    };
    pub const Switch = struct {
        ast: Components,
        label_token: ?TokenIndex,
        pub const Components = struct {
            switch_token: TokenIndex,
            conditon: Node.Index,
            cases: []const Node.Index,
        };
    };

    pub const SwitchCase = struct {
        main_token: TokenIndex,
        pub const Components = struct {
            values: []const Node.Index,
            do_token: TokenIndex,
            target_expr: Node.Index,
        };
    };
    pub const Call = struct {
        ast: Components,
        pub const Components = struct {
            lparen: TokenIndex,
            fn_expr: Node.Index,
            params: []const Node.Index,
        };
    };
};
