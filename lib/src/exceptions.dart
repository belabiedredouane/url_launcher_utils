/// Base exception for all validation errors exposed by this package.
class UrlLauncherUtilsException implements Exception {
  /// Creates a package exception with a human-readable [message].
  const UrlLauncherUtilsException(this.message);

  /// Human-readable description of the failure.
  final String message;

  @override
  String toString() => 'UrlLauncherUtilsException: $message';
}

/// Thrown when input data is malformed or incomplete.
class UrlLauncherValidationException extends UrlLauncherUtilsException {
  /// Creates a validation exception with a human-readable [message].
  const UrlLauncherValidationException(super.message);
}
