// Copyright (c) 2026 Onyedika Nwankwo Benson
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE file in the root directory of this source tree.
const std = @import("std");

pub const Token = struct {
    loc: Loc,
    tag: Tag,

    pub const Loc = struct {
        start: u32,
        end: u32,
    };

    pub const keywords = std.StaticStringMap(Tag).initComptime(.{
        .{ "module", .keyword_module },
        .{ "require", .keyword_require },
        .{ "record", .keyword_record },
        .{ "interface", .keyword_interface },
        .{ "enum", .keyword_enum },
        .{ "error", .keyword_error },
        .{ "union", .keyword_union },
        .{ "var", .keyword_var },
        .{ "const", .keyword_const },
        .{ "function", .keyword_function },
        .{ "pub", .keyword_pub },
        .{ "distinct", .keyword_distinct },
        .{ "if", .keyword_if },
        .{ "then", .keyword_then },
        .{ "else", .keyword_else },
        .{ "elseif", .keyword_elseif },
        .{ "while", .keyword_while },
        .{ "continue", .keyword_continue },
        .{ "break", .keyword_break },
        .{ "do", .keyword_do },
        .{ "for", .keyword_for },
        .{ "in", .keyword_in },
        .{ "end", .keyword_end },
        .{ "return", .keyword_return },
        .{ "switch", .keyword_switch },
        .{ "case", .keyword_case },
        .{ "defer", .keyword_defer },
        .{ "comptime", .keyword_comptime },
        .{ "extern", .keyword_extern },
        .{ "export", .keyword_export },
        .{ "align", .keyword_align },
        .{ "packed", .keyword_packed },
        .{ "inline", .keyword_inline },
        .{ "noinline", .keyword_noinline },
        .{ "callconv", .keyword_callconv },
        .{ "addrspace", .keyword_addrspace },
        .{ "linksection", .keyword_linksection },
        .{ "test", .keyword_test },
    });

    pub fn getKeyword(bytes: []const u8) ?Tag {
        return keywords.get(bytes);
    }

    pub fn isCompilerVar(bytes: []const u8) Tag {
        return if (bytes.len >= 8 and std.mem.eql(u8, "__icbnl_", bytes[0..8])) .comp_var else .identifier;
    }

    pub const Tag = enum {
        keyword_module,
        keyword_require,
        keyword_record,
        keyword_interface,
        keyword_enum,
        keyword_error,
        keyword_union,
        keyword_var,
        keyword_const,
        keyword_function,
        keyword_pub,
        keyword_distinct,
        keyword_if,
        keyword_then,
        keyword_else,
        keyword_elseif,
        keyword_while,
        keyword_continue,
        keyword_break,
        keyword_do,
        keyword_for,
        keyword_in,
        keyword_end,
        keyword_return,
        keyword_switch,
        keyword_case,
        keyword_defer,
        keyword_comptime,
        keyword_extern,
        keyword_export,
        keyword_align,
        keyword_packed,
        keyword_inline,
        keyword_noinline,
        keyword_callconv,
        keyword_addrspace,
        keyword_linksection,
        keyword_test,
        equal,
        equal_equal,
        plus,
        plus_equal,
        minus,
        minus_equal,
        star,
        star_equal,
        slash,
        slash_equal,
        bang,
        bang_equal,
        tilde,
        tilde_equal,
        caret,
        caret_equal,
        l_angle,
        l_angle_equal,
        l_angle_l_angle,
        l_angle_l_angle_equal,
        r_angle,
        r_angle_equal,
        r_angle_r_angle,
        r_angle_r_angle_equal,
        pipe,
        pipe_pipe,
        pipe_equal,
        amperstand,
        amperstand_amperstand,
        amperstand_equal,
        colon,
        colon_equal,
        l_brace,
        r_brace,
        l_paren,
        r_paren,
        l_bracket,
        r_bracket,
        comma,
        char_literal,
        string_literal,
        multi_line_string_literal,
        number_literal,
        identifier,
        question_mark,
        dot,
        dot2,
        dot3,
        dot_question_mark,
        dot_star,
        builtin,
        comp_var,
        comment,
        invalid,
        eof,
        semicolon, // This is for ASI

        pub fn lexeme(tag: Tag) ?[]const u8 {
            return switch (tag) {
                .invalid,
                .char_literal,
                .string_literal,
                .multi_line_string_literal,
                .number_literal,
                .identifier,
                .builtin,
                .comp_var,
                .eof,
                => null,

                .keyword_module => "module",
                .keyword_require => "require",
                .keyword_record => "record",
                .keyword_interface => "interface",
                .keyword_enum => "enum",
                .keyword_error => "error",
                .keyword_union => "union",
                .keyword_var => "var",
                .keyword_const => "const",
                .keyword_function => "function",
                .keyword_pub => "pub",
                .keyword_distinct => "distinct",
                .keyword_if => "if",
                .keyword_then => "then",
                .keyword_else => "else",
                .keyword_elseif => "elseif",
                .keyword_while => "while",
                .keyword_do => "do",
                .keyword_for => "for",
                .keyword_in => "in",
                .keyword_end => "end",
                .keyword_return => "return",
                .keyword_switch => "switch",
                .keyword_case => "case",
                .keyword_defer => "defer",
                .keyword_comptime => "comptime",
                .keyword_extern => "extern",
                .keyword_export => "export",
                .keyword_align => "align",
                .keyword_packed => "packed",
                .keyword_inline => "inline",
                .keyword_noinline => "noinline",
                .keyword_callconv => "callconv",
                .keyword_addrspace => "addrspace",
                .keyword_linksection => "linksection",
                .keyword_test => "test",
                .question_mark => "?",
                .dot => ".",
                .dot2 => "..",
                .dot3 => "...",
                .dot_star => ".*",
                .dot_question_mark => ".?",
                .equal => "=",
                .equal_equal => "==",
                .plus => "+",
                .plus_equal => "+=",
                .minus => "-",
                .minus_equal => "-=",
                .star => "*",
                .star_equal => "*=",
                .slash => "/",
                .slash_equal => "/=",
                .bang => "!",
                .bang_equal => "!=",
                .tilde => "~",
                .tilde_equal => "~=",
                .caret => "^",
                .caret_equal => "^=",
                .l_angle => "<",
                .l_angle_equal => "<=",
                .l_angle_l_angle => "<<",
                .l_angle_l_angle_equal => "<<=",
                .r_angle => ">",
                .r_angle_equal => ">=",
                .r_angle_r_angle => ">>",
                .r_angle_r_angle_equal => ">>=",
                .pipe => "|",
                .pipe_pipe => "||",
                .pipe_equal => "|=",
                .amperstand => "&",
                .amperstand_amperstand => "&&",
                .amperstand_equal => "&=",
                .colon => ":",
                .colon_equal => ":=",
                .l_brace => "{",
                .r_brace => "}",
                .l_paren => "(",
                .r_paren => ")",
                .l_bracket => "[",
                .r_bracket => "]",
                .comma => ",",
                .semicolon => "\n",
            };
        }

        pub fn symbol(tag: Tag) []const u8 {
            return tag.lexeme() orelse switch (tag) {
                .invalid => "invalid token",
                .char_literal => "a char literal",
                .string_literal => "a string literal",
                .multi_line_string_literal => "a multiline string literal",
                .number_literal => "a number literal",
                .identifier => "an identifier",
                .builtin => "a built function",
                .comp_var => "a compiler variable",
                .comment => "a comment",
                .eof => "EOF",
                else => unreachable,
            };
        }
    };
};

const token_string =
    \\{{
    \\  "tag_name": "{s}",
    \\  "string": "{s}",
    \\  "loc":{{
    \\      "start":"{d}",
    \\      "end":"{d}"
    \\  }}
    \\}}
    \\
;
pub const Tokenizer = struct {
    last_token_tag: Token.Tag,
    index: u32,
    buffer: [:0]const u8,

    pub fn dump(self: *Tokenizer, token: *const Token, writer: *std.Io.Writer) !void {
        try writer.print(token_string, .{
            @tagName(token.tag),
            self.buffer[token.loc.start..token.loc.end],
            token.loc.start,
            token.loc.end,
        });
        try writer.flush();
    }

    pub fn isValidASIToken(self: Tokenizer) bool {
        return switch (self.last_token_tag) {
            .identifier,
            .keyword_continue,
            .keyword_break,
            .keyword_return,
            .number_literal,
            .char_literal,
            .multi_line_string_literal,
            .dot_star,
            .dot_question_mark,
            .comp_var,
            .r_paren,
            .r_brace,
            => true,
            else => false,
        };
    }

    pub fn init(buffer: [:0]const u8) Tokenizer {
        return .{
            .last_token_tag = undefined,
            .buffer = buffer,
            .index = if (std.mem.startsWith(u8, buffer, "\xEF\xBB\xBF")) 3 else 0,
        };
    }

    const State = enum {
        start,
        invalid,
        int,
        int_period,
        int_exponent,
        float,
        float_exponent,
        l_angle,
        l_angle_l_angle,
        r_angle,
        r_angle_r_angle,
        bang,
        equal,
        plus,
        minus,
        star,
        slash,
        pipe,
        amperstand,
        tilde,
        caret,
        colon,
        comment,
        multi_line_string,
        string,
        string_backslash,
        char,
        char_backslash,
        identifier,
        builtin,
        carraige_return,
        dot,
        dot_dot,
        newline,
    };
    pub fn next(self: *Tokenizer) Token {
        var result: Token = .{
            .tag = undefined,
            .loc = .{
                .start = self.index,
                .end = undefined,
            },
        };

        state: switch (State.start) {
            .start => switch (self.buffer[self.index]) {
                0 => {
                    if (self.index == self.buffer.len) {
                        return .{
                            .tag = .eof,
                            .loc = .{
                                .end = self.index,
                                .start = self.index,
                            },
                        };
                    } else {
                        continue :state .invalid;
                    }
                },

                ' ', '\t' => {
                    self.index += 1;
                    result.loc.start = self.index;
                    continue :state .start;
                },
                ',' => {
                    self.index += 1;
                    result.tag = .comma;
                },

                '?' => {
                    self.index += 1;
                    result.tag = .question_mark;
                },
                '{' => {
                    self.index += 1;
                    result.tag = .l_brace;
                },

                '}' => {
                    self.index += 1;
                    result.tag = .r_brace;
                },

                '(' => {
                    self.index += 1;
                    result.tag = .l_paren;
                },

                ')' => {
                    self.index += 1;
                    result.tag = .r_paren;
                },

                '[' => {
                    self.index += 1;
                    result.tag = .l_bracket;
                },

                ']' => {
                    self.index += 1;
                    result.tag = .r_bracket;
                },

                'a'...'z', 'A'...'Z', '_' => {
                    result.tag = .identifier;
                    continue :state .identifier;
                },

                '0'...'9' => {
                    result.tag = .number_literal;
                    continue :state .int;
                },

                '"' => {
                    result.tag = .string_literal;
                    continue :state .string;
                },
                '\'' => {
                    result.tag = .char_literal;
                    continue :state .char;
                },
                '`' => {
                    result.tag = .multi_line_string_literal;
                    continue :state .multi_line_string;
                },

                '\n' => continue :state .newline,
                '#' => continue :state .comment,
                '\r' => continue :state .carraige_return,
                '.' => continue :state .dot,
                '!' => continue :state .bang,
                '+' => continue :state .plus,
                '-' => continue :state .bang,
                '*' => continue :state .star,
                '/' => continue :state .bang,
                '<' => continue :state .l_angle,
                '>' => continue :state .r_angle,
                '&' => continue :state .amperstand,
                '|' => continue :state .pipe,
                '^' => continue :state .caret,
                ':' => continue :state .colon,
                '~' => continue :state .tilde,
                '@' => continue :state .builtin,
                '=' => continue :state .equal,
                else => continue :state .invalid,
            },

            .newline => {
                self.index += 1;
                if (self.isValidASIToken()) {
                    result.tag = .semicolon;
                } else {
                    result.loc.start = self.index;
                    continue :state .start;
                }
            },

            .carraige_return => {
                self.index += 1;
                if (self.index < self.buffer.len and self.buffer[self.index] == '\n') {
                    self.index += 1;
                }

                if (self.isValidASIToken()) {
                    result.tag = .semicolon;
                } else {
                    result.loc.start = self.index;
                    continue :state .start;
                }
            },
            .dot => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '.' => continue :state .dot_dot,
                    '*' => {
                        self.index += 1;
                        result.tag = .dot_star;
                    },

                    '?' => {
                        self.index += 1;
                        result.tag = .dot_question_mark;
                    },
                    else => result.tag = .dot,
                }
            },
            .dot_dot => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '.' => result.tag = .dot3,
                    else => result.tag = .dot2,
                }
            },
            .bang => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .bang_equal;
                        self.index += 1;
                    },
                    else => result.tag = .bang,
                }
            },
            .caret => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .caret_equal;
                        self.index += 1;
                    },
                    else => result.tag = .caret,
                }
            },
            .colon => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .colon_equal;
                        self.index += 1;
                    },
                    else => result.tag = .colon,
                }
            },
            .equal => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .equal_equal;
                        self.index += 1;
                    },
                    else => result.tag = .equal,
                }
            },

            .plus => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .plus_equal;
                        self.index += 1;
                    },
                    else => result.tag = .plus,
                }
            },

            .minus => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .minus_equal;
                        self.index += 1;
                    },
                    else => result.tag = .minus,
                }
            },

            .star => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .star_equal;
                        self.index += 1;
                    },
                    else => result.tag = .star,
                }
            },

            .slash => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .slash_equal;
                        self.index += 1;
                    },
                    else => result.tag = .slash,
                }
            },

            .amperstand => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .amperstand_equal;
                        self.index += 1;
                    },
                    '&' => {
                        result.tag = .amperstand_amperstand;
                        self.index += 1;
                    },
                    else => result.tag = .amperstand,
                }
            },

            .pipe => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .pipe_equal;
                        self.index += 1;
                    },
                    '|' => {
                        result.tag = .pipe_pipe;
                        self.index += 1;
                    },
                    else => result.tag = .pipe,
                }
            },

            .tilde => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .tilde_equal;
                        self.index += 1;
                    },
                    else => result.tag = .tilde,
                }
            },

            .l_angle => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .l_angle_equal;
                        self.index += 1;
                    },
                    '<' => continue :state .l_angle_l_angle,
                    else => result.tag = .l_angle,
                }
            },

            .l_angle_l_angle => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .l_angle_l_angle_equal;
                        self.index += 1;
                    },
                    else => result.tag = .l_angle_l_angle,
                }
            },

            .r_angle => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .r_angle_equal;
                        self.index += 1;
                    },
                    '>' => continue :state .r_angle_r_angle,
                    else => result.tag = .r_angle,
                }
            },

            .r_angle_r_angle => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '=' => {
                        result.tag = .r_angle_r_angle_equal;
                        self.index += 1;
                    },
                    else => result.tag = .r_angle_r_angle,
                }
            },

            .builtin => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0, '\n' => result.tag = .invalid,
                    '"' => {
                        result.tag = .identifier;
                        continue :state .string;
                    },
                    'a'...'z', 'A'...'Z', '_' => continue :state .builtin,
                    else => result.tag = .builtin,
                }
            },
            .int => switch (self.buffer[self.index]) {
                '.' => continue :state .int_period,
                'a'...'d', 'g'...'o', 'q'...'z', 'A'...'D', 'G'...'O', 'Q'...'Z', '0'...'9', '_' => {
                    self.index += 1;
                    continue :state .int;
                },
                'e', 'E', 'p', 'P' => {
                    continue :state .int_exponent;
                },
                else => {},
            },
            .int_period => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    'a'...'d', 'g'...'o', 'q'...'z', 'A'...'D', 'G'...'O', 'Q'...'Z', '0'...'9', '_' => {
                        self.index += 1;
                        continue :state .float;
                    },
                    'e', 'E', 'p', 'P' => {
                        continue :state .float_exponent;
                    },
                    else => self.index -= 1,
                }
            },
            .int_exponent => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '-', '+' => {
                        self.index += 1;
                        continue :state .float;
                    },
                    else => continue :state .int,
                }
            },
            .float => switch (self.buffer[self.index]) {
                'a'...'d', 'g'...'o', 'q'...'z', 'A'...'D', 'G'...'O', 'Q'...'Z', '0'...'9', '_' => {
                    self.index += 1;
                    continue :state .float;
                },
                'e', 'E', 'p', 'P' => {
                    continue :state .float_exponent;
                },
                else => {},
            },
            .float_exponent => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    '-', '+' => {
                        self.index += 1;
                        continue :state .float;
                    },
                    else => continue :state .float,
                }
            },

            .string => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            continue :state .invalid;
                        } else {
                            result.tag = .invalid;
                        }
                    },
                    '"' => self.index += 1,
                    '\n' => result.tag = .invalid,
                    '\\' => continue :state .string_backslash,
                    0x01...0x09, 0x0b...0x1f, 0x7f => {
                        continue :state .invalid;
                    },
                    else => continue :state .string,
                }
            },
            .string_backslash => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0, '\n' => result.tag = .invalid,
                    0x01...0x09, 0x0b...0x1f, 0x7f => {
                        continue :state .invalid;
                    },
                    else => continue :state .string,
                }
            },

            .char => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            continue :state .invalid;
                        } else {
                            result.tag = .invalid;
                        }
                    },
                    '\'' => self.index += 1,
                    '\n' => result.tag = .invalid,
                    '\\' => continue :state .char_backslash,
                    0x01...0x09, 0x0b...0x1f, 0x7f => {
                        continue :state .invalid;
                    },
                    else => continue :state .char_backslash,
                }
            },
            .char_backslash => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0, '\n' => result.tag = .invalid,
                    0x01...0x09, 0x0b...0x1f, 0x7f => {
                        continue :state .invalid;
                    },
                    else => continue :state .char,
                }
            },

            .multi_line_string => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            continue :state .invalid;
                        } else {
                            result.tag = .invalid;
                        }
                    },
                    '\n' => continue :state .multi_line_string,
                    '`' => {
                        result.tag = .multi_line_string_literal;
                        self.index += 1;
                    },
                    '\r' => if (self.buffer[self.index + 1] != '\n') {
                        continue :state .invalid;
                    },
                    0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => continue :state .invalid,
                    else => continue :state .multi_line_string,
                }
            },
            .comment => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0 => {
                        if (self.index == self.buffer.len) {
                            result.tag = .comment;
                        } else {
                            continue :state .invalid;
                        }
                    },
                    '\n' => {
                        result.tag = .comment;
                        self.index += 1;
                    },
                    else => continue :state .comment,
                }
            },

            .identifier => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => continue :state .identifier,
                    else => {
                        const ident = self.buffer[result.loc.start..self.index];
                        if (Token.getKeyword(ident)) |tag| {
                            result.tag = tag;
                        } else {
                            result.tag = Token.isCompilerVar(ident);
                        }
                    },
                }
            },

            .invalid => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0 => if (self.index == self.buffer.len) {
                        result.tag = .invalid;
                    } else {
                        continue :state .invalid;
                    },
                    '\n' => result.tag = .invalid,
                    else => continue :state .invalid,
                }
            },
        }

        result.loc.end = self.index;
        self.last_token_tag = result.tag;
        return result;
    }
};
