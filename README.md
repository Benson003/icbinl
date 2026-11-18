<!--- Copyright (c) 2026 Onyedika Nwankwo Benson
All rights reserved.

This source code is licensed under the BSD 3-Clause License found in the
LICENSE file in the root directory of this source tree. --->
# ICBINL — I Can't Believe It's Not Lua

**ICBINL** is an ahead-of-time (AOT) compiled, systems-grade programming language that pairs Lua's clean, readable `end`-delimited syntax with strict static typing, deterministic memory control, and zero garbage collection overhead.

## Core Design Pillars

* **Lua Ergonomics, Systems Guarantees:** Familiar block structure (`if ... then ... end`, `while ... do ... end`) with newline-driven Automatic Semicolon Insertion (ASI)—no curly-brace noise or mandatory semicolons.

* **Explicit Memory & Pointer Semantics:**

  * `^T`, `^[*]T`, and `^[]T` explicitly denote single-item pointers, many-item pointers, and slices (dereferenced via `ptr.*`).

  * `&` for references.

  * Arbitrary bit-width integers (`u1`–`u65535`, `i1`–`i65535`), `packed` records, and explicit `align(N)` attributes give direct control over hardware memory layouts.

* **Flat Colon Namespacing (`M:Member`):** Attach enums, sub-types, variables, and methods directly to a parent container or namespace at the top level (`M:A enum`, `M:reset function`) and access them cleanly via dot notation (`M.A`, `M.reset`).

* **Compile-Time Execution & C ABI Interop:** First-class `comptime` evaluation, `defer` scope cleanup, `@` builtins, and seamless C ABI compatibility via `extern` and `export`.

## Quick Taste of ICBINL

```
module sensor
require "./hardware"

# Strongly typed distinct wrapper
Celsius distinct f32

pub align(4) packed record SensorState
    active: u1
    channel: u7
    reading: Celsius
end

# Attach an enum directly to the SensorState namespace
SensorState::Status enum
    Idle
    Sampling
    Fault
end

# Attach a method to SensorState using colon syntax
SensorState::reset function(self: ^SensorState): ()
    self.active = 0
    self.reading = 0.0
end

export function sample_all(sensors: ^[]SensorState): u32
    var count := 0
    defer @log("Sampling pass complete")

    for &s in sensors do
        if s.*.active == 1 && s.*.channel > 0 then
            count += 1
        end
    end

    return count
end

```

## Compiler Status & Architecture

* **Tokenizer (`tokenizer.zig`):** Complete state-machine lexer supporting 38 keywords, ASI newline-to-semicolon insertion, `#` comments, raw backtick multiline strings, `@` builtins, and symbolic bitwise/logical operators.

* **AST (`ast.zig`):** Index-packed `MultiArrayList` node layout with `extra_data` span encoding for cache-local traversal.

* **Parser & Semantic Analysis:** In active development.

## Documentation

* [Language Reference & EBNF Grammar](doc/reference.md)

## License

Copyright (c) 2026 Onyedika Nwankwo Benson. Licensed under the **BSD 3-Clause License**.
