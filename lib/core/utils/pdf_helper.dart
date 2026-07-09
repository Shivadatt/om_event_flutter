import 'pdf_helper_stub.dart'
    if (dart.library.html) 'pdf_helper_web.dart'
    if (dart.library.io) 'pdf_helper_io.dart'
    as impl;

class PdfHelper {
  PdfHelper._();

  static Future<void> saveAndLaunchPdf(List<int> bytes, String fileName) async {
    await impl.saveAndLaunchPdfImpl(bytes, fileName);
  }
}
