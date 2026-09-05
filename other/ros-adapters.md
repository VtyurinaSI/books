# ROS And ROS2 Adapters

Use this reference when touching ROS nodes, callbacks, params, messages, TF, QoS, timestamps, lifecycle nodes, or bag replay behavior.

## Adapter Principle

A ROS node is an adapter around core logic, not the algorithm itself.

Keep the core algorithm usable without ROS. The adapter should convert transport-specific data, call core, and translate results back.

## Callback Policy

- Keep callback bodies short.
- Convert messages to core types at the boundary.
- Do not put registration math, state-machine logic, config validation policy, or map update algorithms directly in callbacks.
- Do not let ROS message types leak into core headers.
- Convert ROS time, frames, covariance, and units explicitly.
- Validate frame assumptions at adapter boundaries.
- Convert `core::Error` to ROS logs/status in one place.

## Params And Config

- ROS param reading belongs in `ros_adapters`.
- Core config structs belong in `core`.
- Core owns authoritative validation.
- The adapter should preserve original ROS parameter names in error messages.
- Invalid config should fail loudly with structured errors; do not silently replace invalid values with defaults.

## TF, Frames, And Time

- State transform direction in names, for example `T_world_body`.
- Verify whether a transform maps from B to A before composing it.
- Specify timestamp policy: message time, receipt time, interpolation, tolerance, and stale data handling.
- Handle bag replay and out-of-order timestamps intentionally.
- Normalize quaternions at boundaries where external data enters core.
- Keep units explicit: meters, radians, seconds, nanoseconds, covariance convention.

## QoS And Runtime Behavior

- Document topics, frames, QoS, queue depth, lifecycle behavior, and parameter update policy where they affect correctness.
- Avoid hidden global node state.
- Avoid unnecessary point-cloud copies; prefer views/spans and move ownership only where the type system supports it.
- Rate-limit high-frequency logging in the adapter or app layer.

## Diagnostics Translation

- Core diagnostics are structured events.
- ROS adapters translate them to `RCLCPP_*`, `diagnostic_msgs`, tracing, or metrics.
- Keep diagnostic category names stable.
- Tests may inject a collecting diagnostic sink into core and assert emitted diagnostics without ROS.
