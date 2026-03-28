import 'package:flutter/foundation.dart';

import 'exceptions.dart';

/// Describes how a launch attempt completed.
enum LaunchStatus {
  /// The originally requested URI opened successfully.
  launchedPrimary,

  /// The primary URI failed, but a fallback store URI opened successfully.
  launchedFallback,

  /// Neither the primary URI nor any fallback URI could be opened.
  failed,
}

/// Immutable result returned by every public launcher method.
@immutable
class LaunchResult {
  /// Creates a successful result for a primary launch.
  const LaunchResult.launchedPrimary({
    required this.requestedUri,
  })  : status = LaunchStatus.launchedPrimary,
        fallbackUri = null,
        error = null;

  /// Creates a successful result for a fallback launch.
  const LaunchResult.launchedFallback({
    required this.requestedUri,
    required this.fallbackUri,
    this.error,
  }) : status = LaunchStatus.launchedFallback;

  /// Creates a failed result.
  const LaunchResult.failed({
    required this.requestedUri,
    this.fallbackUri,
    this.error,
  }) : status = LaunchStatus.failed;

  /// Final launch state.
  final LaunchStatus status;

  /// URI requested by the caller.
  final Uri requestedUri;

  /// Store URI attempted after a primary failure, when available.
  final Uri? fallbackUri;

  /// Captured exception, if one was thrown.
  final Object? error;

  /// Whether any launch succeeded.
  bool get isSuccess => status != LaunchStatus.failed;

  /// Whether the fallback URI was used.
  bool get usedFallback => status == LaunchStatus.launchedFallback;
}

/// Represents a location to open in maps.
@immutable
class MapLocation {
  const MapLocation._({
    this.query,
    this.latitude,
    this.longitude,
  });

  /// Creates a text-based location such as an address or place name.
  factory MapLocation.query(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      throw const UrlLauncherValidationException(
        'Map query cannot be empty.',
      );
    }

    return MapLocation._(query: normalizedQuery);
  }

  /// Creates a coordinate-based location.
  factory MapLocation.coordinates(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      throw const UrlLauncherValidationException(
        'Latitude must be between -90 and 90.',
      );
    }

    if (longitude < -180 || longitude > 180) {
      throw const UrlLauncherValidationException(
        'Longitude must be between -180 and 180.',
      );
    }

    return MapLocation._(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Human-readable query, when this location was created with [query].
  final String? query;

  /// Latitude, when this location was created with [coordinates].
  final double? latitude;

  /// Longitude, when this location was created with [coordinates].
  final double? longitude;

  /// Whether this location uses a text query.
  bool get isQuery => query != null;

  /// Serialized value compatible with Google Maps URLs.
  String toMapsValue() {
    if (query != null) {
      return query!;
    }

    return '${latitude!},${longitude!}';
  }
}
