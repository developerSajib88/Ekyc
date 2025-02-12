import 'dart:developer';
import 'dart:io';
import 'package:assets_audio_player_plus/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:face_liveness_detection/face_liveness_detection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FaceDetectionScreen extends StatelessWidget {
  const FaceDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FaceDetector();
  }
}

class _FaceDetector extends StatefulWidget {
  const _FaceDetector();

  @override
  State<_FaceDetector> createState() => __FaceDetectorState();
}

class __FaceDetectorState extends State<_FaceDetector> {
  final List<Rulesets> _completedRuleset = [];
  final TextStyle _textStyle = const TextStyle();
  final ValueNotifier<List<XFile>> images = ValueNotifier<List<XFile>>([]);



  String voiceType({required Rulesets rulesets}){
    switch(rulesets){

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
    AssetsAudioPlayerPlus player = AssetsAudioPlayerPlus();
    try {
      await player.open(Audio(voiceType(rulesets: rulesets)));
      await player.play();
    } catch (error, stackTrace) {
      log("Voice Issue: $error", stackTrace: stackTrace, name: "Voice Player");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder(
        valueListenable: images,
        builder: (context,__,_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              ElevatedButton(
                  onPressed: (){
                    playVoice(rulesets: Rulesets.smiling);
                  },
                  child: Text("hello")
              ),


              FaceDetectorView(
                backgroundColor: Colors.transparent,
                  currentRuleset: (rulesets){
                    playVoice(rulesets: rulesets);
                  },
                  images: (image){
                    images.value.add(image);
                    setState(() {});
                    print(images.value);
                    log("Captured Image: $image", name: "Image");
                  },
                  onSuccessValidation: (validated) {
                    log('Face verification is completed', name: 'Validation');
                  },
                  onValidationDone: (controller) {
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
                          ]
                        ],
                      ),
                  onRulesetCompleted: (ruleset) {
                    print("##############################################");
                    if (!_completedRuleset.contains(ruleset)) {
                      _completedRuleset.add(ruleset);
                    }
                  }),
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
              )
            ],
          );
        }
      ),
    );
  }
}

String getHintText(Rulesets state) {
  String hint_ = '';
  switch (state) {
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