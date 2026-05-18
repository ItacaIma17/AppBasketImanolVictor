import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> guardarYAbrirPdf(Uint8List bytes, String nombre) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$nombre');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path);
}
