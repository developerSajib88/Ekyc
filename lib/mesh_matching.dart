import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceRecognition {
  static Future<List<double>?> extractFaceFeatures(File imageFile) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true, // Enables detailed face shape detection
      ),
    );

    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      print("❌ No face detected in ${imageFile.path}");
      return null;
    }

    Face face = faces.first; // Assume only one face

    // Extract facial contours (outline of face, eyes, lips, etc.)
    List<double> featureVector = [];

    void addContour(FaceContourType type) {
      final contour = face.contours[type];
      if (contour != null) {
        for (var point in contour.points) {
          featureVector.add(point.x.toDouble());
          featureVector.add(point.y.toDouble());
        }
      } else {
        featureVector.add(0);
        featureVector.add(0);
      }
    }

    // Add important face contours
    addContour(FaceContourType.face);
    addContour(FaceContourType.upperLipTop);
    addContour(FaceContourType.lowerLipBottom);
    addContour(FaceContourType.leftEyebrowTop);
    addContour(FaceContourType.rightEyebrowTop);

    await faceDetector.close();
    return normalizeVector(featureVector);
  }

  // Normalize features to remove scale dependency
  static List<double> normalizeVector(List<double> vector) {
    double meanX = 0, meanY = 0;
    for (int i = 0; i < vector.length; i += 2) {
      meanX += vector[i];
      meanY += vector[i + 1];
    }
    meanX /= (vector.length ~/ 2);
    meanY /= (vector.length ~/ 2);

    for (int i = 0; i < vector.length; i += 2) {
      vector[i] -= meanX;
      vector[i + 1] -= meanY;
    }
    return vector;
  }

  static double cosineSimilarity(List<double> vec1, List<double> vec2) {
    if (vec1.length != vec2.length) return 0.0; // Avoid errors

    double dotProduct = 0, norm1 = 0, norm2 = 0;
    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }

    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }

  static Future<double> matchFaces(File image1, File image2) async {
    List<double>? features1 = await extractFaceFeatures(image1);
    List<double>? features2 = await extractFaceFeatures(image2);

    if (features1 == null || features2 == null) return 0.0; // No face detected

    double similarity = cosineSimilarity(features1, features2) * 100; // Convert to percentage
    print("✅ Face Similarity: $similarity%");

    return similarity;
  }
}
