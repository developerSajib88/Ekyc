import 'dart:developer';
import 'dart:io';
import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:ekyc/mesh_matching.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:face_liveness_detection/face_liveness_detection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionScreen extends StatelessWidget {
  final File nidFaceImage;
  const FaceDetectionScreen({super.key, required this.nidFaceImage});

  @override
  Widget build(BuildContext context) {
    return _FaceDetector(nidFaceImage: nidFaceImage);
  }
}

class _FaceDetector extends StatefulWidget {
  final File nidFaceImage;
  const _FaceDetector({required this.nidFaceImage});

  @override
  State<_FaceDetector> createState() => __FaceDetectorState();
}

class __FaceDetectorState extends State<_FaceDetector> {
  final List<Rulesets> _completedRuleset = [];
  final TextStyle _textStyle = const TextStyle();
  final ValueNotifier<List<XFile>> images = ValueNotifier<List<XFile>>([]);
  late AssetsAudioPlayerPlus player;


  String voiceType({required Rulesets rulesets}){
    switch(rulesets){

      case Rulesets.notFound:
        return "assets/voices/not_found.mp3";

      case Rulesets.smiling:
        return "assets/voices/smile.mp3";

      case Rulesets.blink:
        return "assets/voices/blink.mp3";

      case Rulesets.toRight:
        return "assets/voices/right.mp3";

      case Rulesets.toLeft:
        return "assets/voices/left.mp3";

      case Rulesets.tiltUp:
        return "assets/voices/up.mp3";

      case Rulesets.tiltDown:
        return "assets/voices/down.mp3";

      case Rulesets.complete:
        return "assets/voices/complete.mp3";

    }
  }


  Future<void> playVoice({required Rulesets rulesets}) async {
    player = AssetsAudioPlayerPlus();
    try {
      await player.open(Audio(voiceType(rulesets: rulesets)));
      await player.play();
    } catch (error, stackTrace) {
      log("Voice Issue: $error", stackTrace: stackTrace, name: "Voice Player");
    }
  }



  /// Face Matching Code
  ///
  ///



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




  File? testImage;
  double faceMatching = 0.0;

  Future<void> detectFacesAndCompare() async {

    File faceImage = File(images.value[0].path);

    await detectFace(faceImage).then((face)async{
      if(face != null){
        await cropFace(File(images.value[0].path),face).then((croppedImage)async{
            if(croppedImage != null){

              testImage = croppedImage;
              setState(() {});

              faceMatching = await MeshMatching.matchFaces(File(images.value[0].path), croppedImage);
              setState(() {});
            }
        });
      }
    });
  }




  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder(
        valueListenable: images,
        builder: (context,__,_) {
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                if(images.value.length != 6)
                FaceDetectorView(
                  backgroundColor: Colors.transparent,
                    hasFace: (bool hasFace){
                      if(hasFace){
                        player.pause();
                      }else{
                        playVoice(rulesets: Rulesets.notFound);
                      }
                    },
                    currentRuleset: (rulesets){
                      playVoice(rulesets: rulesets);
                    },
                    images: (image){
                      images.value.add(image);
                      setState(() {});
                      log("Captured Image: $image", name: "Image");
                    },
                    onSuccessValidation: (validated) {
                      if(validated) player.dispose();
                    },
                    onValidationDone: (controller) {
                      player.dispose();
                      return const SizedBox.shrink();
                    },
                    child: ({required countdown, required state, required hasFace}) =>
                        Column(
                          children: [

                            Row(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Image.asset('assets/face_verification_icon.png',
                                  //     height: 30, width: 30),


                                  const SizedBox(height: 50),

                                  Flexible(
                                      child: AnimatedSize(
                                          duration: const Duration(milliseconds: 150),
                                          child: Text(
                                            hasFace
                                                ? 'User face found'
                                                : 'User face not found',
                                            style: _textStyle.copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12),
                                          )))
                                ]),
                            Text(getHintText(state),
                                style: _textStyle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20)),
                            if (countdown > 0)
                              Text.rich(
                                textAlign: TextAlign.center,
                                TextSpan(children: [
                                  const TextSpan(text: 'IN'),
                                  const TextSpan(text: '\n'),
                                  TextSpan(
                                      text: countdown.toString(),
                                      style: _textStyle.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22))
                                ]),
                                style: _textStyle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              )
                            else ...[
                              const SizedBox(height: 10),
                              const CupertinoActivityIndicator()
                            ],

                          ],
                        ),
                    onRulesetCompleted: (ruleset) {
                      if (!_completedRuleset.contains(ruleset)) {
                        _completedRuleset.add(ruleset);
                      }
                    }
                    ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [


                      Text("Match: ${faceMatching.toString()}"),


                      if(testImage != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.file(
                            testImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),

                          const SizedBox(width: 10),

                          Image.file(
                            widget.nidFaceImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),

                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.value.map((image){
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              File(image.path),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),


                      if(images.value.isNotEmpty)
                        ElevatedButton(
                            onPressed: ()async{
                              await detectFacesAndCompare();
                            },
                            child: const Text("Face Matching")
                        )


                    ],
                  )

              ],
            ),
          );
        }
      ),
    );
  }
}

String getHintText(Rulesets state) {
  String hint_ = '';
  switch (state) {

    case Rulesets.notFound:
      break;
    case Rulesets.smiling:
      hint_ = 'Please Smile';
      break;
    case Rulesets.blink:
      hint_ = 'Please Blink';
      break;
    case Rulesets.tiltUp:
      hint_ = 'Please Look Up';
      break;
    case Rulesets.tiltDown:
      hint_ = 'Please Look Down';
      break;
    case Rulesets.toLeft:
      hint_ = 'Please Look Left';
      break;
    case Rulesets.toRight:
      hint_ = 'Please Look Right';
      break;
    case Rulesets.complete:
      hint_ = 'Complete';

  }
  return hint_;
}