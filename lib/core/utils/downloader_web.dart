import 'dart:html' as html;
import 'dart:typed_data';

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  final blob = html.Blob([
    Uint8List.fromList(bytes),
  ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
