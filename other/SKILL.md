---
name: cpp-module-design
description: Design, implement, refactor, or review maintainable C++ modules with explicit API contracts, ownership, RAII, typed errors, diagnostics, testability, CMake target boundaries, and separation between core, ROS adapters, and app code. Use when a task mentions C++ module architecture, public headers, classes, interfaces, Result/Status error handling, config validation, enum parsing, diagnostics, RAII, ownership/lifetime, ROS/ROS2 adapter boundaries, or core/app layering.
---

# C++ Module Design

Use this skill to keep C++ module work small, explicit, and testable. Prefer the current repository's conventions first; apply this skill as a design and review checklist where the repo is silent or inconsistent.

## Workflow

1. Inspect the project structure before changing code: `README`, `AGENTS.md`, `CMakeLists.txt`, `CMakePresets.json`, `package.xml`, `.clang-format`, CI files, and nearby modules.
2. Identify the requested operation: design, implementation, refactor, or review.
3. For any non-trivial C++ module boundary, read `references/module-design.md`, then load only the topic references needed for the task.
4. State the smallest coherent slice: module responsibility, layer placement, files/targets affected, and tests to update.
5. Keep dependencies pointing inward: `app -> ros_adapters -> core` and `app -> core`. Do not let `core` depend on ROS, UI, CLI, logging macros, or process wiring.
6. Implement only the minimum change needed. Add abstractions only for real variation points, test boundaries, ABI/plugin seams, or established project patterns.
7. Verify with the narrowest relevant build/test/format commands available in the repo. Do not claim verification without command output.

## API Rules

- Treat public headers as contracts: responsibility, inputs/outputs, ownership, failure modes, and caller obligations must be visible from the API.
- Prefer value types and composition over inheritance. Use runtime polymorphism only for real substitution.
- Use RAII for every resource and make ownership explicit in the type system.
- Use `Result<T>`/`Status` or the project's equivalent for expected recoverable failures at module boundaries.
- Keep config as value types with defaults and core validation; keep YAML/ROS/CLI/env parsing in adapters or app code.
- Keep diagnostics structured and adapter-neutral in `core`; translate them to ROS logs, diagnostic messages, or app logging at the boundary.
- Centralize enum string conversion and parsing; do not scatter string literals across adapters.
- Keep headers self-contained, avoid `using namespace` in headers, and keep implementation details in `.cpp` or private detail headers only when justified.

## ROS/ROS2 Boundary

- Keep callbacks thin: convert messages/params/time/frames, call core, convert outputs back.
- Do not put math, state-machine logic, or config validation policy directly in ROS callbacks.
- Make TF direction, timestamp policy, frame ids, QoS, units, and out-of-order handling explicit where relevant.
- Test core without ROS first; test ROS conversions and node behavior separately.

## Output Shape

For module design, use:

1. Module responsibility
2. Layer placement
3. Public types and invariants
4. Public interfaces and functions
5. Ownership and lifetime model
6. Error model
7. Config model and validation
8. Diagnostics policy
9. File tree and CMake targets
10. Test plan
11. Risks and rejected alternatives

For implementation or review, lead with concrete files, target boundaries, correctness risks, and verification steps.

## References

Start with `references/module-design.md` for routing.

- Read `references/api-contracts.md` for public headers, classes, interfaces, ownership, RAII, errors, config, enums, and diagnostics.
- Read `references/layering-and-build.md` for `core / ros_adapters / app`, include structure, and target-based CMake.
- Read `references/ros-adapters.md` for ROS/ROS2 callbacks, params, messages, TF, QoS, timestamp policy, and diagnostics translation.
- Read `references/testing-and-review.md` for tests, static analysis, review checklist, output format, and redesign red flags.
- Read `references/minimal-skeleton.md` only when a compact implementation skeleton is useful.
