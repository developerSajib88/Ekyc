import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecognizerScreen extends StatefulWidget {
  final XFile image;
  const RecognizerScreen({super.key,required this.image});

  @override
  State<RecognizerScreen> createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {

  ValueNotifier<String?> text = ValueNotifier<String?>(null);

  Future<void> recognizeText()async{
    await TextRecognizer(
        script: TextRecognitionScript.devanagiri
    ).processImage(
        InputImage.fromFile(File(widget.image.path))
    ).then((scannedText){
      text.value = scannedText.text;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recognizeText();
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
            valueListenable: text,
            builder: (context,_,__) {
              return Visibility(
                visible: text.value != null,
                replacement: const Center(child: CircularProgressIndicator(color: Colors.blue),),
                child: Text(
                  text.value ?? ""
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
