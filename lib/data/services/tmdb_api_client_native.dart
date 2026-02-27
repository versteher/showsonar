import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Configure Dio for native platforms (macOS, iOS, Android).
/// Bypasses the system proxy to avoid network content filter issues.
void configureDio(Dio dio) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.findProxy = (uri) => 'DIRECT';
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );
}
