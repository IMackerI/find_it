import 'dart:convert';
import 'dart:io';

import 'models.dart';
import 'remote_api_client_base.dart';

RemoteApiClient createHttpRemoteApiClient({
  required String baseUrl,
  String syncPath = '/sync',
}) {
  return _HttpRemoteApiClient(baseUrl: baseUrl, syncPath: syncPath);
}

class _HttpRemoteApiClient implements RemoteApiClient {
  _HttpRemoteApiClient({
    required this.baseUrl,
    required this.syncPath,
    HttpClient? httpClient,
  }) : _httpClient = httpClient ?? HttpClient();

  final String baseUrl;
  final String syncPath;
  final HttpClient _httpClient;

  Uri get _syncUri {
    final base = Uri.parse(baseUrl);
    final pathUri = Uri.parse(syncPath);
    return base.resolveUri(pathUri);
  }

  @override
  Future<SyncResponse> sync(SyncRequest request) async {
    final uri = _syncUri;
    final httpRequest = await _httpClient.postUrl(uri);
    httpRequest.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    httpRequest.add(utf8.encode(jsonEncode(request.toJson())));
    final response = await httpRequest.close();
    final responseBody = await utf8.decoder.bind(response).join();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.trim().isEmpty) {
        return SyncResponse.empty();
      }
      final dynamic decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return SyncResponse.fromJson(decoded);
      }
      throw const FormatException('Unexpected sync response payload');
    }
    throw HttpException(
      'Failed to sync (${response.statusCode}): $responseBody',
      uri: uri,
    );
  }

  @override
  Future<void> dispose() async {
    _httpClient.close();
  }
}
