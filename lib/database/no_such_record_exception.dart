/// NoSuchRecordException
///
/// Thrown when a search fails to find a matching [HeathRecord]
final class NoSuchRecordException implements Exception {
  String cause;

  NoSuchRecordException(this.cause);
}
