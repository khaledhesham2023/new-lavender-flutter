class Env {
  static const baseUrl = String.fromEnvironment('BASE_URL');
  static const hostUrl = String.fromEnvironment('HOST_URL');
  static const host = String.fromEnvironment('HOST');
  static const paymentKey = String.fromEnvironment('PAYMENT_KEY');
  static bool get isConfigured => baseUrl.isNotEmpty;
}
