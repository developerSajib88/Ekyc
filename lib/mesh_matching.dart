import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';


class MeshMatching{
//
//   static final faceMeshDetector = FaceMeshDetector(
//     option: FaceMeshDetectorOptions.faceMesh,
//   );
//
// // Get face mesh points from an image
//   static Future<List<FaceMeshPoint>?> getFaceMeshPoints(File imageFile) async {
//
//
//     try {
//       print("📸 Detecting face mesh in: ${imageFile.path}");
//
//       final inputImage = InputImage.fromFile(imageFile);
//       final faceMeshes = await faceMeshDetector.processImage(inputImage);
//
//       if (faceMeshes.isEmpty) {
//         print("❌ No face detected in: ${imageFile.path}");
//         return null;
//       }
//
//       print("✅ Face mesh detected in: ${imageFile.path}");
//       return faceMeshes.first.points;
//     } catch (e) {
//       print("⚠️ Face mesh detection error: $e");
//       return null;
//     } finally {
//       await faceMeshDetector.close(); // ✅ Close after each use
//     }
//   }
//
//
//
//
//
//
// // Compute Euclidean Distance between two points
//   static double euclideanDistance(FaceMeshPoint p1, FaceMeshPoint p2) {
//     return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2) + pow(p1.z - p2.z, 2));
//   }
//
// // Compare two face meshes (returns true if similarity ≥ 60%)
//   static Future<double> matchFaceImages(File image1, File image2) async {
//
//     List<FaceMeshPoint>? mesh1 = await getFaceMeshPoints(image1);
//     List<FaceMeshPoint>? mesh2 = await getFaceMeshPoints(image2);
//
//
//     print("Mesh1: $mesh1");
//     print("Mesh2: $mesh2");
//
//     if (mesh1 == null || mesh2 == null) return 100; // No face detected
//
//     List<int> keyIndexes = [1, 4, 33, 61, 91, 133, 263, 291, 321, 356]; // Key points
//     double totalDifference = 0;
//
//     for (int i in keyIndexes) {
//       totalDifference += euclideanDistance(mesh1[i], mesh2[i]);
//     }
//
//     double similarityScore = 100 - (totalDifference / keyIndexes.length * 10); // Normalize
//     //return similarityScore >= 60;
//     print("//✅ Match if similarity is $similarityScore% or more");
//     return similarityScore; //✅ Match if similarity is 60% or more
//   }


  static Future<List<double>?> extractFaceEmbeddings(File imageFile) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true, // Enables facial feature detection
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        // Enables face probability
      ),
    );

    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      print("❌ No face detected in ${imageFile.path}");
      return null;
    }

    Face face = faces.first; // Assuming only one face

    // Generate a simple feature vector using key facial landmarks
    List<double> featureVector = [
      face.boundingBox.left, face.boundingBox.top, face.boundingBox.width, face.boundingBox.height,
      face.headEulerAngleX ?? 0, face.headEulerAngleY ?? 0, face.headEulerAngleZ ?? 0
    ];

    await faceDetector.close();
    return featureVector;
  }



  static double cosineSimilarity(List<double> vec1, List<double> vec2) {
    double dotProduct = 0, norm1 = 0, norm2 = 0;

    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }

    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }


  static Future<double> matchFaces(File image1, File image2) async {
    List<double>? features1 = await extractFaceEmbeddings(image1);
    List<double>? features2 = await extractFaceEmbeddings(image2);

    if (features1 == null || features2 == null) return 0.0; // No face detected

    double similarity = cosineSimilarity(features1, features2) * 100; // Convert to percentage
    print("✅ Face Similarity: $similarity%");

    return similarity; // Match threshold
  }




}
