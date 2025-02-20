import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:ekyc/view/face_detection_screen.dart';
import 'package:ekyc/view/recognizer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

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


  File? frontPart;
  File? backPart;


  DocumentScannerOptions documentOptions = DocumentScannerOptions(
    documentFormat: DocumentFormat.jpeg, // set output document format
    mode: ScannerMode.filter, // to control what features are enabled
    pageLimit: 1, // setting a limit to the number of pages scanned
    isGalleryImport: false, // importing from the photo gallery
  );



  Future<void> startScan({bool isFrontPart = false})async{
    await DocumentScanner(options: documentOptions).scanDocument().then((document){
      if(isFrontPart) {
        frontPart = File(document.images[0]);
      } else {
        backPart = File(document.images[0]);
      }
      setState(() {});
    });

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan NID Card"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Front and Back boxes with Dotted Borders and enhanced styling
            Column(
              children: [
                // Front Part Box with Dotted Border
                GestureDetector(
                  onTap: () => startScan(isFrontPart: true),
                  child: DottedBorder(
                    color: Colors.blue, // Dotted border color
                    strokeWidth: 3, // Thicker border for more visibility
                    borderType: BorderType.RRect, // Rounded corners
                    radius: const Radius.circular(15), // Rounded corners for the border
                    padding: const EdgeInsets.all(10), // Padding inside the dotted border
                    child: Container(
                      width: double.infinity, // Full-width container
                      height: 250, // Adjusted height for better aspect ratio
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, // Soft background color
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: frontPart == null
                          ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                          SizedBox(height: 10),
                          Text(
                            "Scan Front",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )
                          : Image.file(frontPart!, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Back Part Box with Dotted Border
                GestureDetector(
                  onTap: () => startScan(),
                  child: DottedBorder(
                    color: Colors.green, // Dotted border color
                    strokeWidth: 3, // Thicker border for more visibility
                    borderType: BorderType.RRect, // Rounded corners
                    radius: const Radius.circular(15), // Rounded corners for the border
                    padding: const EdgeInsets.all(10), // Padding inside the dotted border
                    child: Container(
                      width: double.infinity, // Full-width container
                      height: 250, // Adjusted height for better aspect ratio
                      decoration: BoxDecoration(
                        color: Colors.green.shade50, // Soft background color
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: backPart == null
                          ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.green),
                          SizedBox(height: 10),
                          Text(
                            "Scan Back",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      )
                          : Image.file(backPart!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Next Button - Floating and Elevated
            GestureDetector(
              onTap: (){

              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    if(frontPart != null && backPart != null){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          RecognizerScreen(
                            frontPart: frontPart!,
                            backPart: backPart!,
                          )
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blueAccent, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded button
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



