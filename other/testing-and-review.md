# Testing And Review

Use this reference before finalizing implementation, running review, or deciding whether a design is acceptable.

## Test Strategy

- Test `core` without ROS.
- Instantiate configs, domain types, fake diagnostic sinks, fake clocks, and fake dependencies directly.
- Test behavior, not private implementation details.
- Do not make private functions public only for tests.
- Do not add `friend` test fixtures just to inspect internals.
- If private logic is complex, extract a small class or free function with a clear API.
- Test success paths, invalid config, error propagation, enum parsing, ownership/move behavior, and diagnostics.
- Test adapter conversions separately from core algorithms.
- Add ROS integration tests only after core behavior is covered.

## Static Analysis And Build Hygiene

- Prefer warning-clean code.
- Use project warning settings first.
- For GCC/Clang, consider `-Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Woverloaded-virtual -Wnull-dereference` when consistent with the project.
- For MSVC, prefer `/W4 /permissive-`.
- Use clang-tidy where feasible: `cppcoreguidelines-*`, `modernize-*`, `performance-*`, `readability-*`, `bugprone-*`, `clang-analyzer-*`, `misc-*`.
- Use sanitizers in tests when available: ASan, UBSan, TSan for concurrency-sensitive code, leak checks where supported.
- Do not silence warnings by weakening types or adding unexplained casts.

## Design Output Format

When asked to design a module, produce:

1. Module responsibility
2. Layer placement
3. Public types and invariants
4. Public interfaces and functions
5. Ownership and lifetime model
6. Error model
7. Config model and validation
8. Enum parsing and serialization policy
9. Diagnostics policy
10. File tree and CMake targets
11. Test plan
12. Risks and rejected alternatives
13. Minimal implementation skeleton if requested

When asked to implement, first state the files that will change, then implement the smallest coherent slice.

## Review Checklist

- Does the module have one clear responsibility?
- Are volatile dependencies outside `core`?
- Does every public function state failures through `Result<T>`, `Status`, exceptions, or documented preconditions?
- Are all owning relationships explicit?
- Is every resource managed by RAII?
- Are raw pointers non-owning and nullable by design?
- Are arrays/ranges represented as spans or containers?
- Are configs value types with validation?
- Are enum string conversions centralized?
- Are diagnostics structured and adapter-neutral in `core`?
- Are headers self-contained and free of ROS leakage?
- Are interfaces small and data-free?
- Are class invariants established at construction or through a factory?
- Are move/copy/destructor operations intentional?
- Are tests possible without private access hacks?
- Are target dependencies acyclic?

## Red Flags

Stop and redesign if you see:

- `core` includes `rclcpp` or ROS message headers.
- A class named `Manager`, `Helper`, `Utils`, or `Context` owns unrelated concerns.
- A public API returns `bool` and logs the reason for failure.
- A function has several adjacent primitive parameters with the same type.
- Ownership is described only in comments while the type says `T*`.
- A constructor leaves an object invalid until `init()` is called.
- A destructor can throw.
- A base class has both virtual functions and data members without strong justification.
- A test needs `#define private public`.
- Enum parsing is implemented with scattered string comparisons.
- Configuration is read from globals or ROS params inside algorithms.
- Diagnostics are emitted directly through ROS macros from core.
- There is a dependency cycle between libraries.
