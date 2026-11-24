import 'dart:typed_data';

/// A receipt photo picked from the camera or the gallery.
class ReceiptImage {
  const ReceiptImage({required this.bytes, required this.mimeType});

  /// Raw bytes of the photo.
  final Uint8List bytes;

  /// Media type sent to the AI, such as `image/jpeg`.
  final String mimeType;
}
