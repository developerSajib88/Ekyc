import 'dart:io';

import 'package:ekyc/view/face_detection_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class RecognizerScreen extends StatefulWidget {
  final File image;
  const RecognizerScreen({super.key,required this.image});

  @override
  State<RecognizerScreen> createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  ValueNotifier<bool> isNotNIDCard = ValueNotifier<bool>(false);
  ValueNotifier<Map<String,String>?> data = ValueNotifier<Map<String,String>?>(null);
  ValueNotifier<File?> nidFace = ValueNotifier<File?>(null);

  // Future<void> recognizeText()async{
  //   await TextRecognizer(
  //       script: TextRecognitionScript.devanagiri
  //   ).processImage(
  //       InputImage.fromFile(widget.image)
  //   ).then((scannedText){
  //     scannedText.blocks.forEach((bloc){
  //       print(bloc.text);
  //       bloc.lines.forEach((line){
  //         print("hi>>>${line.elements.last.text}");
  //       });
  //     });
  //     text.value = scannedText.text;
  //   });
  // }









  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    return recognizedText.text;
  }



  Map<String, String>? parseNIDData(String text) {
    Map<String, String> nidData = {};

    // Extract Name (assuming name follows "Name:")
    RegExp nameRegex = RegExp(r'Name:\s*(.*)');
    Match? nameMatch = nameRegex.firstMatch(text);
    if (nameMatch != null) {
      nidData['Name'] = nameMatch.group(1) ?? '';
    }else{
      return null;
    }

    // Extract Date of Birth
    RegExp dobRegex = RegExp(r'Date of Birth:\s*([\d]{1,2} [A-Za-z]+ \d{4})');
    Match? dobMatch = dobRegex.firstMatch(text);
    if (dobMatch != null) {
      nidData['Date of Birth'] = dobMatch.group(1) ?? '';
    }else{
      return null;
    }

    // Extract ID Number (assuming format of a long number)
    RegExp idRegex = RegExp(r'ID NO:\s*(\d{10,17})');
    Match? idMatch = idRegex.firstMatch(text);
    if (idMatch != null) {
      nidData['ID Number'] = idMatch.group(1) ?? '';
    }else{
      return null;
    }

    return nidData;
  }

  bool isNIDCard(String extractedText) {
    List<String> nidKeywords = ["National ID", "Govt. of", "ID No", "Date of Birth"];
    for (var keyword in nidKeywords) {
      if (extractedText.contains(keyword)) {
        return true;
      }
    }
    return false;
  }


  Future<void> detectNIDCard() async {

    String extractedText = await extractText(widget.image);
    if(isNIDCard(extractedText)){
      data.value = parseNIDData(extractedText);
    }else{
      isNotNIDCard.value = true;
    }
    print("Extracted NID Data: ${data.value}");
  }




  /// ======CAPTURED NID FACE==========

  Future<Face?> detectFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableContours: true, enableLandmarks: true),
    );

    final List<Face> faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();

    if (faces.isEmpty) {
      print("No face detected.");
      return null;
    }

    return faces.first; // Assuming the first detected face is the NID profile image
  }


  Future<File?> cropFace(File imageFile, Face face) async {
    // Load the image
    img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());
    if (originalImage == null) return null;

    // Get the bounding box of the detected face
    final boundingBox = face.boundingBox;
    int x = boundingBox.left.toInt();
    int y = boundingBox.top.toInt();
    int width = boundingBox.width.toInt();
    int height = boundingBox.height.toInt();

    // Ensure cropping values are within the image bounds
    x = x.clamp(0, originalImage.width);
    y = y.clamp(0, originalImage.height);
    width = width.clamp(0, originalImage.width - x);
    height = height.clamp(0, originalImage.height - y);

    // Crop the face region
    img.Image croppedFace = img.copyCrop(originalImage, x: x, y: y, width: width, height: height);

    // Save the cropped image
    File faceImageFile = File(imageFile.path.replaceAll('.jpg', '_face.jpg'))
      ..writeAsBytesSync(img.encodeJpg(croppedFace));

    return faceImageFile;
  }



  Future<void> extractNIDProfileImage() async {

    Face? face = await detectFace(widget.image);
    if (face == null) {
      print("No face found on the NID card.");
      return;
    }

    File? faceImage = await cropFace(widget.image, face);
    if (faceImage != null) {
      nidFace.value = faceImage;
      print("Profile image extracted and saved at: ${faceImage.path}");
    }
  }




  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    detectNIDCard().whenComplete((){
      extractNIDProfileImage().whenComplete((){
        isLoading.value = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(10),
          child: ValueListenableBuilder(
            valueListenable: isNotNIDCard,
            builder: (context,__,_) {
              return Visibility(
                visible: isNotNIDCard.value == false,
                replacement: const Center(
                  child: Text(
                      "This isn't valid NID card. Please scan your NID card"
                  ),
                ),
                child: ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (context,_,__) {
                    return Visibility(
                      visible: isLoading.value == false,
                      replacement: const Center(child: CircularProgressIndicator(color: Colors.blue),),
                      child: ValueListenableBuilder(
                        valueListenable: data,
                        builder: (context,__,_) {
                          return Visibility(
                            visible: data.value != null,
                            replacement: const Center(
                              child: Text(
                                "We can't detect. Please Try again!"
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                ValueListenableBuilder(
                                    valueListenable: nidFace,
                                    builder: (_,__,___)=>
                                      nidFace.value == null ?
                                        const Icon(Icons.account_circle)
                                      : Image.file(
                                         nidFace.value!
                                      )
                                ),

                                Text("Name : ${data.value?["Name"]}"),
                                const SizedBox(height: 10),
                                Text("Date of Birth : ${data.value?["Date of Birth"]}"),
                                const SizedBox(height: 10),
                                Text("ID Number : ${data.value?["ID Number"]}"),
                                const SizedBox(height: 10),


                                ElevatedButton(
                                    onPressed: (){
                                      if(nidFace.value != null){
                                        Navigator.push(context, CupertinoPageRoute(
                                            builder: (context)=> FaceDetectionScreen(nidFaceImage: nidFace.value!)
                                        ));
                                      }
                                    },
                                    child: const Text("Face Verify")
                                ),

                              ],
                            ),
                          );
                        }
                      ),
                    );
                  }
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
