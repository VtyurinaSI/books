# C++ Module Design Reference Map

Use this file as the entry point for detailed C++ module design guidance. Load only the reference files needed for the current task.

## Source Orientation

This skill is shaped by the local design-book collection in `/home/sheykinmo/Документы/cpp-books/books/design`:

- API stability and boundary design from API-focused C++ material.
- Physical dependency management and package boundaries from large-scale C++ design material.
- RAII, value semantics, testability, and sustainable code practices from clean/practical C++ design material.
- Design patterns as named tools, not default architecture, from modern C++ patterns material.

Do not quote or reproduce book text. Use these sources as background for concise engineering rules.

## Reference Files

- `api-contracts.md`: public headers, classes, interfaces, ownership, RAII, error model, config, enums, diagnostics.
- `layering-and-build.md`: `core / ros_adapters / app` boundaries, headers/sources, target-based CMake, dependency direction.
- `ros-adapters.md`: ROS/ROS2 adapter rules, callbacks, params, TF/time/frame policy, diagnostics translation.
- `testing-and-review.md`: test strategy, static analysis, review checklist, red flags, output format.
- `minimal-skeleton.md`: small implementation skeleton for a new core module.

## Routing

- Designing a new module: read `api-contracts.md`, `layering-and-build.md`, and `testing-and-review.md`.
- Implementing a core class or API: read `api-contracts.md` and `minimal-skeleton.md`.
- Touching ROS/ROS2 nodes, params, messages, TF, QoS, or callbacks: read `ros-adapters.md` and `layering-and-build.md`.
- Changing CMake targets or include structure: read `layering-and-build.md`.
- Reviewing code: read `testing-and-review.md`; add other references only for the affected area.
- Debugging geometry, TF, or timing bugs: read `ros-adapters.md` first, then project-specific code.

## Global Rules

- Prefer the repository's established conventions over this skill where they are explicit and coherent.
- Make the smallest correct change that preserves module boundaries.
- Add abstractions only for real variation points, tests, plugin/ABI seams, or repeated complexity.
- Treat public headers as API contracts.
- Keep ownership, lifetime, error handling, configuration, and diagnostics explicit.
- Do not put volatile integration details into `core`.
