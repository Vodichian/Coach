/// NoSuchProfileException
///
/// Thrown when a search fails to find a matching [Profile]
final class NoSuchProfileException implements Exception {
  String cause;

  NoSuchProfileException(this.cause);
}
