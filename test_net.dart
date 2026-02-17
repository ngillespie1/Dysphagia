import 'dart:io';
void main() async {
  print('Testing connection...');
  var client = HttpClient();
  client.connectionTimeout = Duration(seconds: 5);
  try {
    var request = await client.getUrl(Uri.parse('https://pub.dev'));
    var response = await request.close();
    print('Status: ${response.statusCode}');
  } catch (e) {
    print('Error: $e');
  }
  exit(0);
}
