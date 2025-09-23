import 'models.dart';

abstract class RemoteApiClient {
  Future<SyncResponse> sync(SyncRequest request);
  Future<void> dispose();
}

class NoopRemoteApiClient implements RemoteApiClient {
  @override
  Future<SyncResponse> sync(SyncRequest request) async {
    return SyncResponse.empty();
  }

  @override
  Future<void> dispose() async {}
}
