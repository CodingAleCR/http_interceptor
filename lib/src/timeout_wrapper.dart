import 'dart:async';

/// Wraps [action] in a [Duration] timeout and optionally invokes [onTimeout].
///
/// If [timeout] is null, [action] runs with no timeout. If the timeout fires,
/// [onTimeout] is called (if non-null) and a [TimeoutException] is thrown.
Future<T> withTimeout<T>({
  required Future<T> Function() action,
  Duration? timeout,
  void Function()? onTimeout,
}) async {
  if (timeout == null || timeout == Duration.zero) return action();
  return action().timeout(
    timeout,
    onTimeout: onTimeout != null
        ? () {
            onTimeout();
            throw TimeoutException('Request timed out after $timeout');
          }
        : null,
  );
}
