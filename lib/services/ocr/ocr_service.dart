import 'package:flutter/foundation.dart';
import 'dart:math';

class OcrService {
  /// Simulates OCR scanning by returning a random reasonable expense amount
  /// To implement real OCR: 
  /// 1. Add `google_mlkit_text_recognition`
  /// 2. Initialize `TextRecognizer`
  /// 3. Pass image file, extract `RecognizedText`
  /// 4. Apply RegEx to find highest currency-like number block.
  static Future<double?> extractTotalAmountFromImage(String imagePath) async {
    // Artificial delay to simulate processing
    await Future.delayed(const Duration(seconds: 2));
    
    debugPrint("Mock OCR extracting from: $imagePath");
    
    // Simulate finding a total (e.g., $15.99, $42.50)
    final random = Random();
    final value = 5.0 + random.nextDouble() * 150.0;
    
    return double.parse(value.toStringAsFixed(2));
  }
}
