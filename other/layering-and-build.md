# Layering And Build

Use this reference when defining file layout, target boundaries, include structure, or dependency direction.

## Contents

- Dependency Direction
- Layer Responsibilities
- File Layout
- Header And Source Rules
- Target-Based CMake

## Dependency Direction

Use this direction unless the existing project has a stronger established convention:

```text
app -> ros_adapters -> core
app -> core
core -> standard library and approved pure C++ libraries only
```

Do not introduce cyclic target dependencies. Do not let `core` depend on ROS, Qt, app globals, CLI parsing, logging macros, YAML node types, process exit, or UI code.

## Layer Responsibilities

`core` owns:

- Domain types and algorithms.
- State machines and mathematical code.
- Resource-owning C++ wrappers.
- Config validation.
- Structured errors and diagnostics.
- Pure C++ interfaces.

`ros_adapters` owns:

- ROS params to core config.
- ROS messages to core input types.
- Core outputs to ROS messages.
- Core diagnostics to ROS logging or diagnostic messages.
- ROS time, frame, QoS, lifecycle, and transport assumptions.

`app` owns:

- Process entry points.
- Dependency wiring.
- Runtime mode selection.
- Node/executor creation.
- Config source selection.
- Top-level error handling and shutdown policy.

## File Layout

For a library-style package, prefer:

```text
include/<project>/
  core/
  ros_adapters/
  app/
src/
  core/
  ros_adapters/
  app/
tests/
  core/
  ros_adapters/
  app/
```

Public headers live under `include/<project>/...`. Private headers live under `src/...`, or `include/<project>/detail/...` only when several translation units need a shared private contract.

Do not expose `detail` headers as stable API.

## Header And Source Rules

- Headers are self-contained.
- A `.cpp` file includes its own public header first.
- Headers contain declarations, type definitions, templates, inline functions, `constexpr` constants, and aliases.
- Headers do not contain non-inline function definitions or mutable object definitions.
- Do not put `using namespace` in headers.
- Use forward declarations to reduce compile-time coupling when they do not make the API obscure.
- Include what you use in `.cpp` files.
- Avoid cyclic includes.
- Keep private helpers in `.cpp` unnamed namespaces or private `detail` namespaces.
- Use Pimpl only for ABI stability, compile-time isolation, or hiding heavy dependencies.

## Target-Based CMake

Preserve the existing target structure. Add dependencies to the narrowest target that needs them.

```cmake
add_library(project_core
    src/core/scan_matcher.cpp
    src/core/scan_matcher_config.cpp)

target_include_directories(project_core PUBLIC include)
target_compile_features(project_core PUBLIC cxx_std_23)

add_library(project_ros_adapters
    src/ros_adapters/scan_matcher_node.cpp
    src/ros_adapters/scan_matcher_params.cpp)

target_link_libraries(project_ros_adapters
    PUBLIC project_core
    PRIVATE rclcpp sensor_msgs nav_msgs)

add_executable(project_app src/app/main.cpp)
target_link_libraries(project_app PRIVATE project_core project_ros_adapters)
```

Never link `project_core` against `rclcpp` or ROS message packages.
