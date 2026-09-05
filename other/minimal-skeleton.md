# Minimal Module Skeleton

Use this skeleton for a new core module, then remove anything the real module does not need. Replace `project`, `example`, and domain names with project-specific names.

## Contents

- Foundation Types
- Config Header
- Processor Header
- Processor Implementation
- Skeleton Rules

## Foundation Types

Use the project's existing error/result foundation if present. If the project has no equivalent, a compact C++23 baseline can look like this:

```cpp
#pragma once

#include <expected>
#include <source_location>
#include <string>
#include <utility>

namespace project::core {

enum class ErrorCode {
    invalid_argument,
    invalid_config,
    parse_error,
    io_error,
    unavailable,
    timeout,
    cancelled,
    invariant_violation,
    internal_error
};

struct Error {
    ErrorCode code{ErrorCode::internal_error};
    std::string message;
    std::source_location location{std::source_location::current()};
};

template <typename T>
using Result = std::expected<T, Error>;

using Status = Result<void>;

[[nodiscard]] inline Error make_error(
    ErrorCode code,
    std::string message,
    std::source_location location = std::source_location::current()) {
    return Error{code, std::move(message), location};
}

} // namespace project::core
```

## Config Header

```cpp
// include/project/core/example/example_config.hpp
#pragma once

#include <project/core/result.hpp>

namespace project::core::example {

struct Config {
    int max_iterations{10};
    double tolerance{1.0e-3};
};

[[nodiscard]] core::Status validate(const Config& config);

} // namespace project::core::example
```

## Processor Header

```cpp
// include/project/core/example/example_processor.hpp
#pragma once

#include <project/core/diagnostic.hpp>
#include <project/core/example/example_config.hpp>
#include <project/core/result.hpp>

#include <span>

namespace project::core::example {

struct Input {
    double value{};
};

struct Output {
    double value{};
};

class Processor {
public:
    Processor(const Processor&) = delete;
    Processor& operator=(const Processor&) = delete;
    Processor(Processor&&) noexcept = default;
    Processor& operator=(Processor&&) noexcept = default;

    [[nodiscard]] static core::Result<Processor> create(Config config,
                                                        DiagnosticSink& diagnostics);

    [[nodiscard]] core::Result<Output> process(std::span<const Input> input);

private:
    Processor(Config config, DiagnosticSink& diagnostics) noexcept;

    Config config_;
    DiagnosticSink* diagnostics_{}; // non-owning, invariant: diagnostics_ != nullptr
};

} // namespace project::core::example
```

## Processor Implementation

```cpp
// src/core/example/example_processor.cpp
#include <project/core/example/example_processor.hpp>

#include <expected>
#include <utility>

namespace project::core::example {

core::Status validate(const Config& config) {
    if (config.max_iterations <= 0) {
        return std::unexpected(core::make_error(
            core::ErrorCode::invalid_config,
            "max_iterations must be positive"));
    }
    if (!(config.tolerance > 0.0)) {
        return std::unexpected(core::make_error(
            core::ErrorCode::invalid_config,
            "tolerance must be positive"));
    }
    return {};
}

core::Result<Processor> Processor::create(Config config, DiagnosticSink& diagnostics) {
    if (auto status = validate(config); !status) {
        return std::unexpected(status.error());
    }
    return Processor{std::move(config), diagnostics};
}

Processor::Processor(Config config, DiagnosticSink& diagnostics) noexcept
    : config_{std::move(config)}, diagnostics_{&diagnostics} {}

core::Result<Output> Processor::process(std::span<const Input> input) {
    if (input.empty()) {
        return std::unexpected(core::make_error(
            core::ErrorCode::invalid_argument,
            "input must not be empty"));
    }

    diagnostics_->emit(Diagnostic{
        .severity = Severity::debug,
        .category = "example.processor",
        .message = "processing input"
    });

    return Output{.value = input.front().value};
}

} // namespace project::core::example
```

## Skeleton Rules

- Keep the skeleton smaller than the real problem.
- Delete `DiagnosticSink` injection if diagnostics are not needed.
- Delete the class if a free function or value type is sufficient.
- Replace primitive fields with domain types when units or invariants matter.
- Add tests before extending the skeleton into a larger framework.
