import 'package:test/test.dart';

// Import all test suites
import 'models/interceptor_contract_test.dart' as interceptor_contract_tests;
import 'models/retry_policy_test.dart' as retry_policy_tests;
import 'models/http_interceptor_exception_test.dart' as exception_tests;
import 'http/http_methods_test.dart' as http_methods_tests;
import 'http/intercepted_client_test.dart' as intercepted_client_tests;
import 'extensions/string_test.dart' as string_tests;
import 'extensions/uri_test.dart' as uri_tests;
import 'utils/query_parameters_test.dart' as query_parameters_tests;

void main() {
  group('HTTP Interceptor Library Tests', () {
    group('Models', () {
      interceptor_contract_tests.main();
      retry_policy_tests.main();
      exception_tests.main();
    });

    group('HTTP Core', () {
      http_methods_tests.main();
      intercepted_client_tests.main();
    });

    group('Extensions', () {
      string_tests.main();
      uri_tests.main();
    });

    group('Utilities', () {
      query_parameters_tests.main();
    });
  });
}
