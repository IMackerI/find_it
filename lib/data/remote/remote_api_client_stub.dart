import 'remote_api_client_base.dart';

RemoteApiClient createHttpRemoteApiClient({
  required String baseUrl,
  String syncPath = '/sync',
}) {
  return NoopRemoteApiClient();
}
