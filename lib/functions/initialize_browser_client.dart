import 'dart:io';

import 'package:http/browser_client.dart';
import 'package:http/http.dart';

Client initializeClient(
  bool Function(X509Certificate, String, int)? badCertificateCallback,
  String Function(Uri)? findProxy,
) {
  return BrowserClient();
}
