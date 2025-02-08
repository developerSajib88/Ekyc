import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:ekyc/view/recognizer_screen.dart';
import 'package:ekyc/widgets/hole_clipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/border_painter.dart';

class CapturedScreen extends StatefulWidget {
  const CapturedScreen({super.key});

  @override
  State<CapturedScreen> createState() => _CapturedScreenState();
}

class _CapturedScreenState extends State<CapturedScreen> {

  ValueNotifier isLoading = ValueNotifier<bool>(true);
  late CameraController controller;

  Future initializeCamera()async{
    await availableCameras().then((cameras){
      if(cameras.isNotEmpty){
        isLoading.value = false;
        controller = CameraController(cameras[0], ResolutionPreset.max);
        controller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        }).catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
              // Handle access errors here.
                break;
              default:
              // Handle other errors here.
                break;
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(()=> initializeCamera());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
            child: ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (context,_,__) {
                return Visibility(
                  visible: isLoading.value == false,
                  replacement: const Center(child: CircularProgressIndicator(color: Colors.blue,),),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [

                      // Blurred Background
                      Positioned.fill(
                        child: CameraPreview(controller),
                      ),
                      // Transparent Cut-Out Effect
                      Center(
                        child: ClipPath(
                          clipper: HoleClipper(),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: 10,
                                sigmaY: 10,
                                tileMode: TileMode.mirror
                            ),
                            child: const SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),

                      // Stroke Border Around the Transparent Hole
                      IgnorePointer(
                        child: CustomPaint(
                          size: const Size(double.infinity, double.infinity),
                          painter: BorderPainter(),
                        ),
                      ),

                      Positioned(
                        bottom: 50,
                        child: InkWell(
                          onTap: ()async{
                            await controller.takePicture().then((image){
                              Navigator.push(context, CupertinoPageRoute(builder: (context)=> RecognizerScreen(image: image)));
                            });
                          },
                          child: const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.blue,
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                );
              }
            )
        ),
      ),
    );
  }
}
