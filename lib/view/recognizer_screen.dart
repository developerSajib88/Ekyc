import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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





  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    detectNIDCard().whenComplete((){
      isLoading.value = false;
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
                              children: [
                                Text("Name : ${data.value?["Name"]}"),
                                const SizedBox(height: 10),
                                Text("Date of Birth : ${data.value?["Date of Birth"]}"),
                                const SizedBox(height: 10),
                                Text("ID Number : ${data.value?["ID Number"]}"),
                                const SizedBox(height: 10)
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
