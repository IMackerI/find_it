import 'remote_api_client_base.dart';
import 'remote_api_client_stub.dart'
    if (dart.library.io) 'remote_api_client_impl.dart' as remote_client_impl;

export 'remote_api_client_base.dart';

RemoteApiClient createHttpRemoteApiClient({
  required String baseUrl,
  String syncPath = '/sync',
}) {
  return remote_client_impl.createHttpRemoteApiClient(
    baseUrl: baseUrl,
    syncPath: syncPath,
  );
}
