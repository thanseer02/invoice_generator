import 'dart:io';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PdfExportService {
  /// Opens the native print dialog (Desktop, Mobile, Web)
  static Future<void> printPdf(Uint8List bytes, String filename) async {
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: filename,
    );
  }

  /// Opens the native share sheet (Android, iOS, macOS) or downloads on Web
  static Future<void> sharePdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  /// Explicitly saves the PDF to the device's Documents directory (Desktop/Mobile)
  /// On Web, this will typically trigger a download (fallback to sharePdf).
  static Future<String?> savePdfLocally(Uint8List bytes, String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// A helper to share specifically via email if possible, or fallback to general share.
  /// Note: Attaching files via mailto: url_launcher is not reliably supported across all OS.
  /// Using Share.shareXFiles is the robust way.
  static Future<void> emailPdf(Uint8List bytes, String filename, {String? email}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    
    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Invoice $filename',
      text: 'Please find the attached invoice.',
    );
  }
}
