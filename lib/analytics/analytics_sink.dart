/// Where sanitized analytics calls go. Screens never talk to Firebase.
library;

abstract class AnalyticsSink {
  Future<void> logEvent(String name, Map<String, Object> params);

  Future<void> setUserId(String id);

  Future<void> setUserProperty(String name, String value);
}
