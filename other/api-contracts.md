# API Contracts

Use this reference when designing or changing public C++ headers, classes, interfaces, ownership, errors, config, enum parsing, or diagnostics.

## Public API Workflow

1. Define the module responsibility in one sentence. If it contains unrelated "and" clauses, split the module or justify the coupling.
2. Define public input and output types. Prefer domain types over primitive parameter lists.
3. Define ownership and lifetime for every pointer, reference, handle, callback, view, and thread.
4. Define the error model: `Result<T>`, `Status`, exceptions, assertions, or documented preconditions.
5. Define configuration as value types with defaults and validation.
6. Define diagnostics as structured events, not logs hidden inside algorithms.
7. Put public contracts in headers and implementation details in `.cpp` files or private detail headers only when justified.

## Classes And Data

- Use `struct` for passive aggregates with no invariant beyond field types.
- Use `class` for invariants, resource ownership, hidden representation, behavior, validation, or state transitions.
- Constructors must create fully initialized objects. Avoid `init()` unless a framework forces it, and isolate that in an adapter.
- Prefer the rule of zero. If copy, move, or destructor behavior is declared or deleted, make the full ownership story intentional.
- Single-argument constructors are `explicit` unless implicit conversion is a deliberate domain operation.
- Move operations should be `noexcept` when they exist.
- Do not expose protected data. Keep invariant-bearing state private.

## Interfaces

- Use runtime polymorphism only for real substitution: tests, plugins, adapter boundaries, ABI seams, or expected extension.
- Keep interface classes small, data-free, and coherent.
- Give interface classes virtual destructors.
- Do not force implementers to provide no-op methods.
- Prefer constructor injection over service locators, singletons, and mutable globals.
- Do not introduce an interface only to share code; prefer composition, free functions, templates with concepts, or small strategy objects.

## Ownership And Lifetime

- `T` means owned by the object or scope.
- `T&` means non-null, non-owning, caller-owned lifetime.
- `const T&` means non-owning read-only access.
- `T*` means nullable, non-owning pointer to one object.
- `std::span<T>` means non-owning contiguous sequence.
- `std::string_view` means non-owning text; do not store it unless lifetime is guaranteed.
- `std::unique_ptr<T>` means unique ownership transfer or storage.
- `std::shared_ptr<T>` means shared ownership only when independent owners must extend lifetime.
- Never transfer ownership through raw pointers or references.
- Do not pass smart pointers unless the function participates in ownership.
- Avoid reference data members in copyable or movable types; use a pointer with a stated invariant or `std::reference_wrapper`.

## RAII

- Wrap every acquire/release pair in an owning type.
- Prefer existing RAII types: containers, strings, smart pointers, locks, `std::jthread`, streams, and framework handles with deterministic destructors.
- Destructors must not throw.
- If cleanup failure matters, provide explicit `close()`/`stop()` returning `Status`; let the destructor do best-effort cleanup.
- Do not rely on manual cleanup at the end of a function; early returns and exceptions must be safe.

## Error Model

- Use the project's existing `Result<T>`, `Status`, `expected`, or equivalent if present.
- Return `Result<T>` when a value is produced or a recoverable error occurs.
- Return `Status` when only success/failure with a reason is needed.
- Mark result-returning functions `[[nodiscard]]`.
- Do not return `bool` for operations that can fail with a reason.
- Use `std::optional<T>` only when absence is a successful expected state.
- Do not log and swallow failures in `core`; propagate structured errors with context.
- Convert third-party exceptions at the boundary where they enter project code.
- Use assertions/contracts for programmer errors and violated internal invariants.

## Configuration

- Config is data. Loading config is an adapter concern. Validation is a core concern.
- Use regular value types with default member initializers.
- Use domain types for units when practical: meters, radians, seconds, frame ids.
- Validate ranges, cross-field invariants, and unsupported combinations in `core`.
- Keep YAML, JSON, CLI, env var, and ROS param parsing outside algorithms.
- Preserve original raw parameter names in adapter error messages.

## Enums

- Prefer `enum class`.
- Do not scatter string literals for enum values.
- Put `to_string()` and `parse_*()` beside the enum.
- `to_string()` should be total and `noexcept`.
- `parse_*()` should return `Result<Enum>` and report unknown input.
- Keep switches exhaustive when compiler warnings can help.
- Document accepted strings and compatibility when an enum crosses a file, network, or ROS boundary.

## Diagnostics

- Separate errors from diagnostics: errors affect control flow; diagnostics help humans and telemetry.
- `core` should emit diagnostics through an injected sink or return structured diagnostic data.
- Do not call ROS logging macros, `std::cout`, or `std::cerr` directly from `core`.
- Use stable diagnostic categories such as `scan_matcher.config` or `registration.degeneracy`.
- Rate-limit high-rate diagnostics in adapters or app unless rate-limiting is domain behavior.
