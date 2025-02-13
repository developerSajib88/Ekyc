import 'dart:developer';
import 'dart:io';

import 'package:ekyc/nid_classifier.dart';
import 'package:ekyc/view/face_detection_screen.dart';
import 'package:ekyc/view/recognizer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {


  DocumentScannerOptions documentOptions = DocumentScannerOptions(
    documentFormat: DocumentFormat.jpeg, // set output document format
    mode: ScannerMode.filter, // to control what features are enabled
    pageLimit: 3, // setting a limit to the number of pages scanned
    isGalleryImport: true, // importing from the photo gallery
  );


  NIDClassifier nidClassifier = NIDClassifier();
  Future<void> scanDocument()async{
    try {
      await DocumentScanner(options: documentOptions).scanDocument().then((document){
         nidClassifier.classifyNID(File(document.images[0]));
         // Navigator.push(context, MaterialPageRoute(builder: (context)=>
         //     RecognizerScreen(
         //         image: File(document.images[0])
         //     )
         // ));
      });
    } on Exception catch (e,stackTrace) {
      log("Document Scan: $e",stackTrace: stackTrace, name: "Document Scan");
    }

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(()=> nidClassifier.loadModel());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ElevatedButton(
            //     onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const CapturedScreen())),
            //     child: const Text("Option 1")
            // ),
            //
            // const SizedBox(height: 10,),


            ElevatedButton(
                onPressed: ()=> scanDocument(),
                child: const Text("NID Scan")
            ),

            const SizedBox(height: 10,),

            ElevatedButton(
                onPressed: ()=> Navigator.push(context, CupertinoPageRoute(builder: (context)=> const FaceDetectionScreen())),
                child: const Text("Face Verify")
            ),


          ],
        ),
      ),
    );
  }
}



