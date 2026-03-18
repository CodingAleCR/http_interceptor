// Platform-specific export for VM and mobile/desktop.
// Import when you need [IOClient] for self-signed certificates or other TLS.
// Do not import on Flutter web—it pulls in dart:io.
export 'http_interceptor.dart';
export 'package:http/io_client.dart' show IOClient;
