import 'package:http/http.dart' as http;

/// Extension on http.Client to support PATCH requests with a body.
extension HttpClientExtensions on http.Client {
  Future<http.Response?> patchAsync(
    Uri url, {
    String? body,
    Map<String, String>? headers,
  }) async {
    http.Response? response;

    try {
      // Use http.Request and then convert to http.Response
      final request = http.Request("PATCH", url)
        ..body = body ?? ''
        ..headers.addAll(headers ?? {});

      final streamedResponse = await this.send(request);
      response = await http.Response.fromStream(streamedResponse);
    } catch (e) {
      print("ERROR: $e");
    }

    return response;
  }
}