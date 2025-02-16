import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class NIDClassifier {
  late Interpreter _interpreter;



  /// Load the TFLite Model
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset("assets/models/screen_detection/fasnet_fine_tuned_v2.tflite");
    print('✅ Model Loaded!');
  }



  /// Preprocess the image: Resize & Normalize
  Uint8List preprocessImage(File imageFile) {
    // Read Image
    Image? image = decodeImage(imageFile.readAsBytesSync());

    // Resize to (80, 80)
    Image resizedImage = copyResize(image!, width: 80, height: 80);

    // Convert to Float List and Normalize
    List<double> normalizedImage = [];
    for (int y = 0; y < 80; y++) {
      for (int x = 0; x < 80; x++) {
        Pixel pixel = resizedImage.getPixel(x, y);
        normalizedImage.add((pixel.r / 255.0 - 0.5) / 0.5);
        normalizedImage.add((pixel.g / 255.0 - 0.5) / 0.5);
        normalizedImage.add((pixel.b / 255.0 - 0.5) / 0.5);
      }
    }

    // Convert the normalized image to a Float32List
    Float32List float32List = Float32List.fromList(normalizedImage);

    // Return the Float32List as a Uint8List
    return float32List.buffer.asUint8List();
  }





  /// Run Model Inference
  Future<String> classifyNID(File imageFile) async {
    var input = preprocessImage(imageFile);

    // Ensure output is a List of doubles
    var output = List.filled(1 * 2, 0.0).reshape([1, 2]); // Ensure float output

    _interpreter.run(input, output);

    // Explicitly cast to List<double>
    List<double> probabilities = List<double>.from(output[0]);

    return probabilities.first >  probabilities.last ? "✅ Real NID" : "❌ Fake NID";
  }

}
