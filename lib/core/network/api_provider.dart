import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

// ApiClient를 전역에서 주입받을 수 있도록 하는 Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});