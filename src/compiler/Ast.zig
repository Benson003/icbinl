// Copyright (c) 2026 Onyedika Nwankwo Benson
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE file in the root directory of this source tree.

const std = @import("std");
const tokenizer = @import("tokenizer.zig");
const Token = tokenizer.Token;
const Tokenizer = tokenizer.Tokenizer;
const Ast = @This();
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

source: [:0]const u8,
extra_data: []u32,
tokens: TokenList.Slice,
node: NodeList.Slice,
errors: []const Error,

pub const ByteOffset = u32;
pub const TokenList = std.MultiArrayList(struct {
    tag: Token.Tag,
    start: ByteOffset,
});

pub const NodeList = std.MultiArrayList(Node);
pub const ExtraIndex = enum(u32) {
    _,
};

pub fn tokenTag(tree: *const Ast, token_index: TokenIndex) Token.Tag {
    return tree.tokens.items(.tag)[token_index];
}

pub fn tokenStart(tree: *const Ast, token_index: TokenIndex) ByteOffset {
    return tree.tokens.items(.start)[token_index];
}

pub fn nodeTag(tree: *const Ast, node: Node.Index) Node.Tag {
    return tree.nodes.items(.tag)[@backingInt(node)];
}

pub fn nodeMainToken(tree: *const Ast, node: Node.Index) TokenIndex {
    return tree.nodes.items(.main_token)[@backingInt(node)];
}

pub fn nodeData(tree: *const Ast, node: Node.Index) Node.Data {
    return tree.nodes.items(.data)[@backingInt(node)];
}

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

pub fn parse(gpa: Allocator, source: [:0]const u8, recover: bool) Allocator.Error!Ast {
    var tokens = Ast.TokenList{};
    defer tokens.deinit(gpa);
    try tokens.ensureTotalCapacity(gpa, source.len);

    var tokenize = Tokenizer.init(source);
    while (true) {
        const token = tokenize.next();
        try tokens.append(gpa, .{
            .start = token.loc.start,
            .tag = token.tag,
        });
        if (token.tag == .eof) break;
    }
    var tokens_slice = tokens.toOwnedSlice();
    errdefer tokens_slice.deinit(gpa);
    return parseTokens(gpa, source, tokens_slice, recover);
}

pub fn parseTokens(gpa: Allocator, source: [:0]const u8, tokens: Ast.TokenList.Slice, recover: bool) Allocator.Error!Ast {
    _ = gpa;
    _ = source;
    _ = tokens;
    _ = recover;
}

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

        global_var_decl,
        local_var_decl,
        simple_var_decl,
        implied_var_decl,

        switch_case,
        switch_case_one,
        switch_case_none,
        switch_range,

        range,

        @"switch",
        @"defer",
        @"while",
        @"for",
        @"if",
        @"continue",
        @"break",
        @"return",
        @"comptime",
        @"orelse",
        @"unreachable",

        fn_proto,
        fn_decl,

        identifier,
        enum_literal,
        string_literal,
        multiline_string_literal,
        char_literal,
        grouped_expression,

        builtin_call_two,
        builtin_call_two_comma,
        builtin_call_one,
        builtin_call_one_comma,
        builtin_call,
        builtin_call_comma,

        error_set_decl,
        error_value,

        field_access,
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
        address_of,
        array_type,
        array_type_sentinel,
        array_access,
        array_init,
        array_init_comma,
        array_init_one,
        array_init_one_comma,
        array_init_two,
        array_init_two_comma,
        record_init,
        record_init_comma,
        record_init_one,
        record_init_one_comma,
        record_init_two,
        record_init_two_comma,
        slice_open,
        slice,
        deref,
        call,
        call_comma,
        call_one,
        call_one_comma,
        container_decl,
        container_decl_comma,
        container_decl_two,
        container_decl_two_comma,
        container_decl_arg,
        container_decl_arg_comma,
        container_field_align,
        container_field_init,
        container_field,
        block_two,
        block_two_comma,
        block,
        block_comma,
        ptr_type,
        ptr_type_senitnel,
        ptr_type_aligned,
        ptr_type_bit_range,
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
        token_and_opt_node: struct { TokenIndex, OptionalIndex },
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

    pub const LocalVarDecl = struct {
        type_node: Index,
        align_node: OptionalIndex,
    };

    pub const ArrayTypeSentinel = struct {
        sentinel: Index,
        elem_type: Index,
    };

    pub const PtrType = struct {
        sentinel: OptionalIndex,
        align_node: OptionalIndex,
        addrspace_node: OptionalIndex,
    };
    pub const PtrTypeBitRange = struct {
        sentinel: OptionalIndex,
        align_node: Index,
        addrspace_node: OptionalIndex,
        bit_range_start: Index,
        bit_range_end: Index,
    };

    pub const If = struct {
        then_expr: Index,
        else_expr: OptionalIndex,
    };

    pub const ContainerField = struct {
        align_expr: Index,
        value_expr: OptionalIndex,
    };
    pub const GlobalVarDecl = struct {
        align_node: OptionalIndex,
        addrspace_node: OptionalIndex,
        section_node: OptionalIndex,
    };

    pub const Slice = struct {
        start: Index,
        end: Index,
    };

    pub const SliceSentinel = struct {
        start: Index,
        end: OptionalIndex,
        sentinel: Index,
    };
    pub const While = struct {
        then_expr: Index,
        else_expr: OptionalIndex,
    };
    pub const For = bitpack struct(u32) {
        inputs: u32,
        has_else: bool,
    };

    pub const FnProtoOne = struct {
        param: OptionalIndex,
        align_expr: OptionalIndex,
        addrspace_expr: OptionalIndex,
        section_expr: OptionalIndex,
        callconv_expr: OptionalIndex,
    };

    pub const FnProto = struct {
        params_strat: OptionalIndex,
        params_end: OptionalIndex,
        align_expr: OptionalIndex,
        addrspace_expr: OptionalIndex,
        section_expr: OptionalIndex,
        callconv_expr: OptionalIndex,
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
        distinct: bool,
    };

    pub const ArrayType = struct {
        ast: Components,
        pub const Components = struct {
            lbracket: TokenIndex,
            elem_count: Node.Index,
            sentinel: Node.OptionalIndex,
            elem_type: Node.Index,
        };
    };

    pub const If = struct {
        else_token: TokenIndex,
        ast: Components,
        pub const Components = struct {
            if_token: TokenIndex,
            cond_expr: Node.Index,
            then: Node.Index,
            else_expr: Node.OptionalIndex,
        };
    };
    pub const For = struct {
        ast: Components,
        inline_token: ?TokenIndex,
        label_token: ?TokenIndex,
        payload_token: TokenIndex,
        pub const Components = struct {
            for_token: TokenIndex,
            inputs: []Node.Index,
            else_expr: Node.OptionalIndex,
        };
    };

    pub const While = struct {
        ast: Components,
        inline_token: ?TokenIndex,
        label_token: ?TokenIndex,
        pub const Components = struct {
            while_token: TokenIndex,
            cond_expr: Node.Index,
            then_expr: Node.Index,
            else_expr: Node.OptionalIndex,
        };
    };

    pub const Slice = struct {
        ast: Components,
        pub const Components = struct {
            sliced: Node.Index,
            lbracket: TokenIndex,
            start: Node.Index,
            end: Node.OptionalIndex,
            sentinel: Node.OptionalIndex,
        };
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
        align_node: Node.OptionalIndex,
        container_tokens: ?[]const TokenIndex,
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
        lib_name: ?TokenIndex,
        comptime_token: ?TokenIndex,
        container_tokens: ?[]const TokenIndex,
        ast: Components,
        implied: bool,
        pub const Components = struct {
            mut_token: ?TokenIndex,
            name_token: TokenIndex,
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
                var_decl.ast.mut_token orelse
                var_decl.ast.name_token;
        }
    };
    pub const Switch = struct {
        ast: Components,
        label_token: ?TokenIndex,
        pub const Components = struct {
            switch_token: TokenIndex,
            condiiton: Node.Index,
            cases: []const Node.Index,
        };
    };

    pub const SwitchCase = struct {
        ast: Components,
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

    pub const StructInit = struct {
        ast: Components,
        pub const Components = struct {
            lbrace: TokenIndex,
            fields: []const Node.Index,
            type_expr: Node.Index,
        };
    };
    pub const ArrayInit = struct {
        ast: Components,
        pub const Components = struct {
            lbracket: TokenIndex,
            lbrace: TokenIndex,
            length_token: Node.Index,
            elements: []const Node.Index,
            type_expr: Node.Index,
        };
    };

    pub const FnProto = struct {
        visib_token: ?TokenIndex,
        export_extern_inline_token: ?TokenIndex,
        lib_name: ?TokenIndex,
        name_token: ?TokenIndex,
        container_tokens: ?[]const TokenIndex,
        lparen: TokenIndex,
        ast: Components,
        pub const Param = struct {
            name_token: ?TokenIndex,
            comptime_token: ?TokenIndex,
            type_expr: ?Node.Index,
            is_varargs: bool,
        };
        pub const Components = struct {
            proto_node: Node.Index,
            fn_token: TokenIndex,
            return_type: []const Node.Index,
            params: []const Node.Index,
            align_expr: Node.OptionalIndex,
            addrspace_expr: Node.OptionalIndex,
            section_expr: Node.OptionalIndex,
            callconv_index: Node.OptionalIndex,
        };

        pub fn firstToken(fn_proto: FnProto) TokenIndex {
            return fn_proto.visib_token orelse
                fn_proto.extern_export_inline_token orelse
                fn_proto.ast.fn_token;
        }
    };
    pub const PtrType = struct {
        size: PtrSize, // .one (^), .many (^[*]), .slice (^[]), etc.
        ast: Components,

        pub const Components = struct {
            main_token: TokenIndex, // The '^' token
            align_expr: Node.OptionalIndex,
            addrspace_expr: Node.OptionalIndex,
            bit_range_start: Node.OptionalIndex,
            bit_range_end: Node.OptionalIndex,
            sentinel: Node.OptionalIndex,
            child_type: Node.Index,
        };
    };

    pub const PtrSize = enum { one, many, slice };
};

pub fn renderError(tree: Ast, err: Error, w: *std.Io.Writer) std.Io.Writer.Error!void {
    switch (err.tag) {
        .unclosed_char => return w.writeAll("unclosed char literal"),
        .unclosed_multiline_string => return w.writeAll("unclosed multiline string"),
        .expected_token => {
            const found = tree.tokenTag(err.token);
            const expected = err.extra.expected_tag;
            return w.print(
                "expected '{s}, found'{s}' ",
                .{
                    expected.symbol(),
                    found.symbol(),
                },
            );
        },

        else => return w.writeAll("unexpected error encountered"),
    }
}

pub const Error = struct {
    tag: Tag,
    token: TokenIndex,
    extra: union {
        none: void,
        expected_tag: Token.Tag,
        offset: usize,
    } = .{ .none = {} },
    pub const Tag = enum {
        expected_do_after_for,
        expected_do_after_while,
        expected_end,
        expected_expr,
        expected_type,
        expected_token,

        unclosed_string,
        unclosed_multiline_string,
        unclosed_char,
        invalid_character,
    };
};
