import 'remote_api_client_base.dart';
import 'remote_api_client_stub.dart'
    if (dart.library.io) 'remote_api_client_impl.dart' as http_impl;

export 'remote_api_client_base.dart';

RemoteApiClient createHttpRemoteApiClient({
  required String baseUrl,
  String syncPath = '/sync',
}) {
  return http_impl.createHttpRemoteApiClient(
    baseUrl: baseUrl,
    syncPath: syncPath,
  );
}
