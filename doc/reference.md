<!--
// Copyright (c) 2026 Onyedika Nwankwo Benson
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause License found in the
// LICENSE file in the root directory of this source tree.
-->

# ICBINL (I Can't Believe It's Not Lua) — Language Reference Specification

Welcome to the official language reference manual for **ICBINL** (*I Can't Believe It's Not Lua*), an ahead-of-time (AOT) compiled, systems-grade programming language. ICBINL adopts Lua's clean, readable syntax layout while strictly enforcing systems-grade performance, static type safety, deterministic memory management, and zero garbage collection overhead.

---

## 1. Keyword Inventory & Keyword Count

ICBINL strips away Lua's runtime dynamicism and global leakage traps, replacing them with a lean, systems-focused vocabulary directly enforced by the compiler's tokenizer.

| Keyword Category | Keywords Included |
| :--- | :--- |
| **Declarations** | `module`, `require`, `record`, `interface`, `enum`, `error`, `union`, `var`, `const`, `function`, `pub`, `distinct` |
| **Control Flow & Blocks** | `if`, `then`, `elseif`, `else`,`orelse`, `while`, `do`, `for`, `in`, `end`, `return`, `switch`, `case`, `defer`, `break`, `continue`,`unreachable` |
| **Metaprogramming** | `comptime` |
| **C ABI & Interop** | `extern`, `export` |
| **Memory & Layout** | `align`, `packed` |
| **Directives & Testing** | `inline`, `noinline`, `callconv`, `addrspace`, `linksection`, `test` |


*(Note: Identifiers prefixed with `__icbnl_` are reserved as internal compiler variables `.comp_var`, and `@` prefixes denote compiler builtins `.builtin`.)*

---

## 2. Operators & Punctuation

ICBINL replaces Lua's keyword-based logical operators (`and`/`or`) with C-style symbolic operators while expanding bitwise and pointer ergonomics.

| Category | Operators / Symbols | Description |
| :--- | :--- | :--- |
| **Arithmetic** | `+`, `-`, `*`, `/` | Standard binary arithmetic |
| **Bitwise** | `&`, `\|`, `~`, `<<`, `>>` | Bitwise AND, OR, NOT, left shift, right shift |
| **Logical** | `&&`, `\|\|`, `!` | Short-circuit logical AND, OR, and logical NOT |
| **Comparison** | `==`, `!=`, `<`, `<=`, `>`, `>=` | Equality and relational comparisons |
| **Assignment & Compound** | `=`, `:=`, `+=`, `-=`, `*=`, `/=`, `&=`, `\|=`, `~=`, `^=`, `<<=`, `>>=` | Direct assignment, inferred initialization (`:=`), and compound updates |
| **Pointers & Optionals** | `^`, `.*`, `.?`, `?` | Pointer type (`^T`), dereference (`.*`), optional unwrap (`.?`), optional modifier (`?`) |
| **Ranges & Variadics** | `..`, `...` | Range expressions (`0..10`) and variadic/spread syntax |
| **Delimiters & Comments** | `( )`, `{ }`, `[ ]`, `:`, `,`, `.`, `#` | Grouping, record init, arrays, type annotations, single-line `#` comments |

---

## 3. Type System & Literals

ICBINL provides rigid, unboxed types that map directly to hardware memory layouts. To eliminate ambiguity:
- Use **`^type`** exclusively for **pointer types** (e.g., `^u32`, `^Point`).
- Use **`&`** exclusively for **reference passing and borrowing** in parameters and loops (e.g., `self: &Point`, `for &item in ls`), as well as binary bitwise AND.

| Category | Type / Literal Notation | Description | Example |
| :--- | :--- | :--- | :--- |
| **Integers** | `u1`–`u65535`, `i1`–`i65535` | Custom bit-width signed/unsigned integers | `var flags: u3 = 7` |
| **Floats** | `f16`, `f32`, `f64` | Standard floating-point types | `var scale: f32 = 1.0` |
| **Distinct Types** | `Name distinct type` | Strongly typed distinct type wrappers | `Cat distinct u32` |
| **Characters & Strings** | `rune`, `string`, `` `...` `` | UTF-8 char (`'a'`), string (`"..."`), and backtick multiline strings | ``var doc: string = `hello` `` |
| **Compile-Time Numbers** | `comptime_int`, `comptime_float` | Arbitrary-precision numbers for compile-time eval | `const MAX: comptime_int = 1000` |
| **Pointers & Optionals** | `^type`, `?type` | Explicit pointer type (`^`) and nullable optional type (`?`) | `var ptr: ?^u32 = null` |
| **Raw Pointers** | `rawptr` | Untyped memory address | `var addr: rawptr = null` |
| **Type Metatype** | `type` | First-class type values at compile time | `const T: type = u32` |
| **Arrays** | `[size:sentinel]type` | Fixed-width or sentinel-terminated arrays | `var buf: [1024:0]u8 = undefined` |

---

## 4. Language Concepts & Examples

### 4.1 Modules, Imports, and Comments
Files are private by default. Single-line comments begin with `#`.

```ibl
# math_utils.ibl
module math_utils
require "./geometry"

pub const PI: f32 = 3.14159
```

### 4.2 Distinct Types
Distinct types create new, incompatible types from existing ones to prevent accidental mixing of domain values.

```ibl
Bat u32
Cat distinct u32

var speed: Bat = 50
# var invalid: Cat = speed # Compile error: type mismatch
```

### 4.3 Records (Structs) with Alignment & Padding
Records define fixed-layout aggregate structures. Memory layout can be tuned using `align` and `packed`.

```ibl
align(4) packed record Vector3
    x: f32
    y: f32
    z: f32
end
```

### 4.4 Interfaces (Inverted Relationship Design)
In ICBINL, interfaces can contain:
1. **Fields:** Shared data layout requirements.
2. **Function Pointer Fields:** Virtual methods that implementing types must provide (what you implement).
3. **Concrete Functions:** Ready-to-use helper functions defined directly on the interface that callers invoke.

```ibl
Drawable interface
    width: u32
    height: u32
    
    # Function pointer field (vtable slot to implement)
    draw: function(self: ^Drawable): void
    
    # Concrete helper function (called directly by consumers)
    function print_dimensions(self: ^Drawable)
        @print(self.width)
    end
end
```

### 4.5 Enums, Unions, and Errors
Custom types handle discrete states, overlapping memory layouts, and failure conditions. Every error type automatically includes an `nerror` sentinel value representing success or absence of error.

```ibl
StatusCode enum
    OK
    Error
end

DataUnion union
    raw: [8]u8
    val: u64
end

FileError error
    NotFound
    PermissionDenied
end
```

### 4.6 C Interoperability (`extern` and `export` Modifiers)
Functions can be marked with `extern` (to link external C symbols) or `export` (to expose ICBINL functions to C code). C-compatible types use the `c_*` prefix.

```ibl
extern function puts(s: ^c_char): c_int

export function compute_sum(a: c_int, b: c_int): c_int
    return a + b
end
```

### 4.7 Control Flow, Loops, and `defer`
ICBINL uses newlines as statement delimiters. Standard control flow includes `if`, `while` (with `break`/`continue`), reference-capturing `for` loops (`&`), `switch`, and `defer`.

```ibl
if x > 10 && is_valid then
    @print("Large")
elseif x == 0 || !is_valid then
    @print("Zero or invalid")
else
    @print("Small")
end

# Reference-capturing loop using &
for &item in items do
    if item == 0 then
        continue
    end
    item += 1
end

var file = open_file("log.txt")
defer close_file(file)
```

### 4.8 Compile-Time Evaluation (`comptime`)
Functions and blocks marked with `comptime` are executed entirely during compilation for zero-runtime-cost generation.

```ibl
comptime function square(x: i32): i32
    return x * x
end

const AREA: i32 = comptime square(10)
```

---

## 5. Complete EBNF Grammar Specification

```ebnf
(* =========================================================================
   ICBINL (I Can't Believe It's Not Lua) - Core EBNF Grammar Specification
   ========================================================================= *)

program ::= { top_level_item }

top_level_item ::= module_decl
                 | require_stmt
                 | record_def
                 | interface_def
                 | function_def
                 | var_def
                 | const_def
                 | enum_def
                 | error_def
                 | union_def
                 | distinct_def
                 | test_def

(* --- Modules & Imports --- *)
module_decl ::= "module" IDENTIFIER NEWLINE
require_stmt ::= "require" STRING_LITERAL NEWLINE

(* --- Type Definitions --- *)
record_def ::= [ "pub" ] [ "align" "(" expression ")" ] [ "packed" ] IDENTIFIER "record" NEWLINE { field_decl } "end" NEWLINE
field_decl ::= IDENTIFIER ":" type NEWLINE

interface_def ::= [ "pub" ] IDENTIFIER "interface" NEWLINE { interface_member } "end" NEWLINE
interface_member ::= ( IDENTIFIER ":" type ) 
                   | ( IDENTIFIER ":" "function" "(" [ parameter_list ] ")" [ ":" type ] )
                   | function_def

enum_def ::= [ "pub" ] IDENTIFIER "enum" NEWLINE { IDENTIFIER NEWLINE } "end" NEWLINE
error_def ::= [ "pub" ] IDENTIFIER "error" NEWLINE { IDENTIFIER NEWLINE } "end" NEWLINE
union_def ::= [ "pub" ] IDENTIFIER "union" NEWLINE { type NEWLINE } "end" NEWLINE
distinct_def ::= [ "pub" ] IDENTIFIER "distinct" type NEWLINE

(* --- Variables & Constants --- *)
var_def ::= [ "pub" ] "var" IDENTIFIER ( ":" type "=" | ":=" ) expression NEWLINE
const_def ::= [ "pub" ] "const" IDENTIFIER ( ":" type "=" | ":=" ) expression NEWLINE

(* --- Functions & Methods --- *)
function_def ::= [ "pub" ] [ "extern" | "export" ] [ "inline" | "noinline" ] [ "comptime" ] "function" IDENTIFIER [ "." IDENTIFIER ] "(" [ parameter_list ] ")" [ ":" type ] NEWLINE block "end" NEWLINE

parameter_list ::= parameter { "," parameter }
parameter ::= [ "&" ] IDENTIFIER ":" type

test_def ::= "test" STRING_LITERAL NEWLINE block "end" NEWLINE

(* --- Types --- *)
type ::= IDENTIFIER 
       | array_type 
       | pointer_type
       | optional_type
       | tuple_type
       | "(" [ type_list ] ")"

array_type ::= "[" expression [ ":" expression ] "]" type
pointer_type ::= "^" type
optional_type ::= "?" type
tuple_type ::= "(" type { "," type } ")"
type_list ::= type { "," type }

(* --- Statements & Control Flow --- *)
block ::= { statement }

statement ::= var_def
            | assignment_stmt
            | return_stmt
            | break_stmt
            | continue_stmt
            | if_stmt
            | while_stmt
            | for_stmt
            | switch_stmt
            | defer_stmt
            | comptime_block
            | expression_stmt

assignment_stmt ::= expression assignment_op expression NEWLINE
assignment_op ::= "=" | "+=" | "-=" | "*=" | "/=" | "&=" | "|=" | "~=" | "^=" | "<<=" | ">>="

return_stmt ::= "return" [ expression_list ] NEWLINE
break_stmt ::= "break" NEWLINE
continue_stmt ::= "continue" NEWLINE

if_stmt ::= "if" expression "then" NEWLINE block 
            { "elseif" expression "then" NEWLINE block } 
            [ "else" NEWLINE block ] 
            "end" NEWLINE

while_stmt ::= "while" expression "do" NEWLINE block "end" NEWLINE

for_stmt ::= "for" [ "&" ] IDENTIFIER "in" expression "do" NEWLINE block "end" NEWLINE

switch_stmt ::= "switch" expression NEWLINE { case_clause } [ else_clause ] "end" NEWLINE
case_clause ::= "case" expression_list "then" NEWLINE block
else_clause ::= "else" NEWLINE block

defer_stmt ::= "defer" statement

comptime_block ::= "comptime" "block" NEWLINE block "end" NEWLINE

expression_stmt ::= expression NEWLINE

(* --- Expressions & Literals --- *)
expression ::= primary_expr { binary_op primary_expr }
             | unary_expr
             | range_expr

unary_expr ::= unary_op primary_expr

primary_expr ::= IDENTIFIER
               | BUILTIN_IDENTIFIER
               | LITERAL
               | MULTILINE_STRING_LITERAL
               | "undefined"
               | record_init
               | function_call
               | postfix_expr
               | "(" expression ")"

postfix_expr ::= primary_expr ( ".*" | ".?" | "." IDENTIFIER )

range_expr ::= expression ( ".." | "..." ) [ "=" ] expression

record_init ::= IDENTIFIER "{" [ field_init_list ] "}"
field_init_list ::= field_init { "," field_init }
field_init ::= IDENTIFIER "=" expression

function_call ::= expression "(" [ expression_list ] ")"
expression_list ::= expression { "," expression }

binary_op ::= "+" | "-" | "*" | "/" | "&" | "|" | "<<" | ">>" | "==" | "!=" | "<" | "<=" | ">" | ">=" | "&&" | "||"

unary_op ::= "~" | "!" | "-"
```
