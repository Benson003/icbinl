<!--- Copyright (c) 2026 Onyedika Nwankwo Benson
All rights reserved.

This source code is licensed under the BSD 3-Clause License found in the
LICENSE file in the root directory of this source tree. --->
# ICBINL (I Can't Believe It's Not Lua) — Language Reference Specification

Welcome to the official language reference manual for **ICBINL** (*I Can't Believe It's Not Lua*), an ahead-of-time (AOT) compiled, systems-grade programming language. ICBINL adopts Lua's clean, readable block layout while strictly enforcing static type safety, deterministic memory management, flat colon-prefixed namespacing, and zero garbage collection overhead.

---

## 1. Lexical Structure & Automatic Semicolon Insertion (ASI)

### 1.1 Comments & Reserved Identifiers
* **Single-Line Comments:** Begin with `#` and extend to the end of the line.
* **Compiler Variables:** Identifiers prefixed with `__icbnl_` are reserved internally by the compiler.
* **Builtins:** Identifiers prefixed with `@` invoke compile-time or low-level compiler builtins (e.g., `@sizeOf`).

### 1.2 Automatic Semicolon Insertion (ASI)
ICBINL uses newlines to delimit statements without requiring explicit `;` characters. During tokenization, a newline (`\n` or `\r\n`) is automatically converted into an internal `.semicolon` statement terminator **only** when immediately preceded by a valid expression-ending token:
* Identifiers, compiler variables (`__icbnl_*`), and literals (`number`, `char`, `multiline_string`)
* Closing delimiters (`)`, `}`)
* Postfix pointer/optional operators (`.*`, `.?`)
* Jump/exit keywords (`return`, `break`, `continue`)

Newlines following binary operators, commas, or opening delimiters are ignored, allowing expressions to span multiple lines naturally without backslash continuations.

---

## 2. Keyword Inventory

ICBINL has vocabulary of **38 keywords**.

| Keyword Category | Keywords Included |
| :--- | :--- |
| **Declarations** | `module`, `require`, `record`, `interface`, `enum`, `error`, `union`, `var`, `const`, `function`, `pub`, `distinct` |
| **Control Flow & Blocks** | `if`, `then`, `elseif`, `else`, `orelse`, `while`, `do`, `for`, `in`, `end`, `return`, `switch`, `case`, `defer`, `break`, `continue`, `unreachable` |
| **Metaprogramming** | `comptime` |
| **C ABI & Interop** | `extern`, `export` |
| **Memory & Layout** | `align`, `packed` |
| **Directives & Testing** | `inline`, `noinline`, `callconv`, `addrspace`, `linksection`, `test` |

---

## 3. Operators & Punctuation

ICBINL replaces Lua's word-based logical operators (`and`, `or`, `not`) with symbolic C-style operators and adds explicit pointer, optional, and type-inference tokens.

| Category | Operators / Symbols | Description |
| :--- | :--- | :--- |
| **Arithmetic** | `+`, `-`, `*`, `/` | Standard binary arithmetic and unary negation (`-`) |
| **Bitwise** | `&`, `|`, `~`, `<<`, `>>` | Bitwise AND, OR, NOT, left shift, right shift |
| **Logical** | `&&`, `||`, `!` | Short-circuit logical AND, OR, and logical NOT |
| **Comparison** | `==`, `!=`, `<`, `<=`, `>`, `>=` | Equality and relational comparisons |
| **Assignment & Binding** | `=`, `:=`, `+=`, `-=`, `*=`, `/=`, `&=`, `|=`, `~=`, `^=`, `<<=`, `>>=` | Explicit assignment, type-inferred declaration (`:=`), and compound updates |
| **Pointers & Optionals** | `^`, `.*`, `.?`, `?`, `orelse` | Pointer modifier (`^`), postfix dereference (`.*`), optional unwrap (`.?`), optional type (`?`), fallback (`orelse`) |
| **Ranges & Variadics** | `..`, `...` | Range expressions (`0..10`) and variadic parameter lists (`...`) |
| **Namespace & Delimiters** | `:`, `.`, `( )`, `{ }`, `[ ]`, `,`, `#` | Colon namespace attachment (`M::A`), member access (`M.A`), grouping, single-line `#` comments |

---

## 4. Type System & Pointers vs. References

ICBINL provides unboxed types that map directly to hardware memory layouts:
* **`^` (Pointers):** Used exclusively for pointer types—single-item pointers (`^T`), many-item pointers (`^[*]T`), C pointers (`rawptr`), and slices (`^[]T`). Dereferenced via postfix `ptr.*`.
* **`&` (References & Address-Of):** Used for reference borrowing in parameters/loops (`self: &Point`, `for &item in items`), address-of expressions, and binary bitwise AND.

| Category | Notation | Description | Example |
| :--- | :--- | :--- | :--- |
| **Arbitrary-Width Integers** | `u1`–`u65535`, `i1`–`i65535` | Signed and unsigned integers of exact bit width | `var flags: u3 = 7` |
| **Floating-Point** | `f16`, `f32`, `f64` | IEEE 754 floating-point types | `var scale: f32 = 1.0` |
| **Unit / Void** | `()` | Empty tuple representing no return value | `function noop(): ()` |
| **Distinct Types** | `Name distinct type` | Strongly typed wrappers incompatible with base type | `Cat distinct u32` |
| **Characters & Strings** | `'c'`, `"..."`, `` `...` `` | Character literals, escaped strings, and raw backtick multiline strings | ``var sql = `SELECT *` `` |
| **Arrays & Slices** | `[N:S]T`, `^[]T` | Fixed-length arrays (with optional sentinel `S`) and slices | `var buf: [1024:0]u8 = undefined` |
| **Optionals** | `?T` | Nullable/optional wrapper unwrapped via `.?` or `orelse` | `var opt: ?u32 = null` |
| **Pointers** | `^T`, `^[*]T` | Single-item, many-item, aligned, or bit-range pointers | `var ptr: ^u32 = &val` |

---

## 5. Language Constructs & Colon Namespacing

### 5.1 Modules, Imports & Declarations
Files are private by default; use `pub` to export symbols. Variables can be explicitly typed (`var`/`const`) or type-inferred (`:=`).

```lua
module math_utils
require "./geometry"

pub const PI: f32 = 3.14159
var counter := 0
```

### 5.2 Flat Colon Namespacing (`M:Member`)
Instead of deep lexical nesting, ICBINL attaches child types, enums, constants, variables, and methods directly to a parent container or namespace using the `:` prefix, while accessing them with `.`.

```lua
M record
    value: u32
end

# Attaches enum A to namespace M (accessed as M.A.new)
M::A enum
    new
    active
end

# Attaches method `reset` to record M
M::reset function(self: ^M): ()
    self.*.value = 0
end
```

### 5.3 Records, Unions, Errors & Interfaces
* **Records:** Support `packed` layout and explicit `align(N)` attributes.
* **Interfaces:** Support shared data fields, vtable function pointer slots, and concrete default helper functions.
* **Errors & Enums:** Discrete tag sets (`enum`) and error sets (`error`).

```lua
align(4) packed record Register
    enabled: u1
    mode: u3
    code: u4
end

Drawable interface
    width: u32
    draw: function(self: ^Drawable): ()
end


M::print_width function (self: ^Drawable): ()
    @print(self.width)
end

```

### 5.4 Control Flow, `defer`, `comptime` & C Interop

```lua
export function compute(items: ^[]u32): u32
    var total: u32 = 0
    defer @log("compute finished")

    for &item in items do
        if item == 0 then
            continue
        end
        total += item
    end

    return total
end
```

---

## 6. Complete EBNF Grammar Specification

```ebnf
(* =========================================================================
   ICBINL (I Can't Believe It's Not Lua) - Core EBNF Grammar Specification
   ========================================================================= *)

program ::= { top_level_item }

top_level_item ::= module_decl
                 | require_stmt
                 | container_def
                 | function_def
                 | var_def
                 | const_def
                 | distinct_def
                 | test_def

(* --- Namespacing Prefix --- *)
namespace_prefix ::= IDENTIFIER ":" { IDENTIFIER ":" }

(* --- Modules & Imports --- *)
module_decl ::= "module" IDENTIFIER NEWLINE
require_stmt ::= "require" STRING_LITERAL NEWLINE

(* --- Type & Container Definitions --- *)
container_def ::= [ "pub" ] [ "align" "(" expression ")" ] [ "packed" ] [ namespace_prefix ] IDENTIFIER container_kind [ "(" expression ")" ] NEWLINE { container_member } "end" NEWLINE
container_kind ::= "record" | "interface" | "enum" | "error" | "union"

container_member ::= [ "comptime" ] IDENTIFIER [ ":" type ] [ "align" "(" expression ")" ] [ "=" expression ] NEWLINE
                   | function_def

distinct_def ::= [ "pub" ] [ namespace_prefix ] IDENTIFIER "distinct" type NEWLINE

(* --- Variables & Constants --- *)
var_def ::= [ "pub" ] [ "extern" | "export" ] [ "comptime" ] [ namespace_prefix ] ( "var" | "const" ) IDENTIFIER [ ":" type ] [ "align" "(" expression ")" ] [ "addrspace" "(" expression ")" ] [ "linksection" "(" expression ")" ] "=" expression NEWLINE
          | [ "pub" ] [ namespace_prefix ] IDENTIFIER ":=" expression NEWLINE

(* --- Functions & Methods --- *)
function_def ::= [ "pub" ] [ "extern" | "export" ] [ "inline" | "noinline" ] [ "comptime" ] [ namespace_prefix ] "function" IDENTIFIER "(" [ parameter_list ] ")" [ "align" "(" expression ")" ] [ "addrspace" "(" expression ")" ] [ "linksection" "(" expression ")" ] [ "callconv" "(" expression ")" ] [ ":" type ] NEWLINE block "end" NEWLINE

parameter_list ::= parameter { "," parameter }
parameter ::= [ "comptime" ] ( [ "&" ] IDENTIFIER ":" type | "..." )

test_def ::= "test" STRING_LITERAL NEWLINE block "end" NEWLINE

(* --- Types --- *)
type ::= IDENTIFIER
       | array_type
       | pointer_type
       | optional_type
       | tuple_type
       | "(" ")"

array_type ::= "[" expression [ ":" expression ] "]" type
pointer_type ::= "^" [ "[" ( "*" | "*c" | ":" expression ) "]" ] [ "align" "(" expression ")" ] [ "addrspace" "(" expression ")" ] type
optional_type ::= "?" type
tuple_type ::= "(" type { "," type } ")"

(* --- Statements & Control Flow --- *)
block ::= { statement }

statement ::= var_def
            | assignment_stmt
            | return_stmt
            | if_stmt
            | while_stmt
            | for_stmt
            | switch_stmt
            | defer_stmt
            | comptime_stmt
            | "break" [ ":" IDENTIFIER ] NEWLINE
            | "continue" [ ":" IDENTIFIER ] NEWLINE
            | expression_stmt

assignment_stmt ::= expression assignment_op expression NEWLINE
assignment_op ::= "=" | "+=" | "-=" | "*=" | "/=" | "&=" | "|=" | "~=" | "^=" | "<<=" | ">>="

return_stmt ::= "return" [ expression ] NEWLINE

if_stmt ::= "if" expression "then" NEWLINE block
            { "elseif" expression "then" NEWLINE block }
            [ "else" NEWLINE block ]
            "end" NEWLINE

while_stmt ::= [ "inline" ] [ IDENTIFIER ":" ] "while" expression "do" NEWLINE block [ "else" NEWLINE block ] "end" NEWLINE

for_stmt ::= [ "inline" ] [ IDENTIFIER ":" ] "for" [ "&" ] IDENTIFIER "in" expression_list "do" NEWLINE block [ "else" NEWLINE block ] "end" NEWLINE

switch_stmt ::= [ IDENTIFIER ":" ] "switch" expression NEWLINE { case_clause } [ else_clause ] "end" NEWLINE
case_clause ::= "case" expression_list "do" NEWLINE block
else_clause ::= "else" NEWLINE block

defer_stmt ::= "defer" statement
comptime_stmt ::= "comptime" ( block "end" NEWLINE | statement )
expression_stmt ::= expression NEWLINE

(* --- Expressions & Literals --- *)
expression ::= unary_expr
             | primary_expr { binary_op primary_expr }
             | range_expr

unary_expr ::= unary_op primary_expr

primary_expr ::= IDENTIFIER
               | COMP_VAR
               | LITERAL
               | "unreachable"
               | builtin_call
               | record_init
               | array_init
               | function_call
               | postfix_expr
               | "(" expression ")"

postfix_expr ::= primary_expr ( ".*" | ".?" | "." IDENTIFIER | "[" expression [ ".." [ expression ] [ ":" expression ] ] "]" )

builtin_call ::= BUILTIN "(" [ expression_list ] ")"
range_expr ::= expression ".." [ expression ]

record_init ::= IDENTIFIER "{" [ field_init_list ] "}"
field_init_list ::= field_init { "," field_init }
field_init ::= IDENTIFIER "=" expression

array_init ::= "[" [ expression ] "]" type "{" [ expression_list ] "}"

function_call ::= expression "(" [ expression_list ] ")"
expression_list ::= expression { "," expression }

binary_op ::= "+" | "-" | "*" | "/"
            | "&" | "|" | "<<" | ">>"
            | "&&" | "||" | "orelse"
            | "==" | "!=" | "<" | "<=" | ">" | ">="

unary_op ::= "~" | "!" | "-" | "&"
```
