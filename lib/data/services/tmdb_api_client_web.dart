import 'package:dio/dio.dart';

/// Configure Dio for web platform.
/// Uses Dio's default BrowserHttpClientAdapter — no special setup needed.
void configureDio(Dio dio) {
  // no-op: the default browser adapter works fine on web
}
