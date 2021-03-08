import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

Client initializeClient(
  bool Function(X509Certificate, String, int)? badCertificateCallback,
  String Function(Uri)? findProxy,
) {
  return IOClient(
    HttpClient()
      ..badCertificateCallback = badCertificateCallback
      ..findProxy = findProxy,
  );
}
