import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<Size> camerasSizes;

  Size bestSize;

  bool _hasInit;

  double scale;

  double bestSizeRatio;

  String _lastPhotoPath;

  bool focus = false;

  ValueNotifier<CameraFlashes> switchFlash = ValueNotifier(CameraFlashes.NONE);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OrientationBuilder(
          builder: (context, orientation) {
            // recalculate for rotation handled here
            if(bestSize != null) {
              final size = MediaQuery.of(context).size;
              bestSizeRatio = bestSize.height / bestSize.width;
              scale = bestSizeRatio / size.aspectRatio;
              if (bestSizeRatio < size.aspectRatio) {
                scale = 1 / scale;
              }
            }
            return Stack(
            children: <Widget>[
              CameraAwesome(
                switchFlashMode: switchFlash,
              ),
              if(_lastPhotoPath != null)
                Positioned(
                  bottom: 52,
                  left: 32,
                  child: Image.file(new File(_lastPhotoPath), width: 128),
                ),
              Positioned(
                bottom: -5,
                left: 0,
                right: 0,
                child: FlatButton(
                  color: Colors.blue,
                  child: Text("take photo", style: TextStyle(color: Colors.white),),
                  onPressed: () async {
                    final Directory extDir = await getTemporaryDirectory();
                    var testDir = await Directory('${extDir.path}/test').create(recursive: true);
                    final String filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                    await CamerawesomePlugin.takePhoto(filePath);
                    setState(() {
                      _lastPhotoPath = filePath;
                    });
                    print("----------------------------------");
                    print("TAKE PHOTO CALLED");
                    print("==> hastakePhoto : ${await File(filePath).exists()}");
                    print("----------------------------------");
                  }
                ),
              ),
              Positioned(
                bottom: 100,
                right: 32,
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      color: Colors.blue,
                      child: Text("focus", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        this.focus = !focus;
                        await CamerawesomePlugin.startAutoFocus();
                      }
                    ),
                    FlatButton(
                      color: Colors.blue,
                      child: Text("flash auto", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        if(switchFlash.value == CameraFlashes.ALWAYS) {
                          switchFlash.value = CameraFlashes.NONE;
                        } else {
                          switchFlash.value = CameraFlashes.ALWAYS;
                        }
                      }
                    ),
                    FlatButton(
                      color: Colors.blue,
                      child: Text("zoom x2", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        await CamerawesomePlugin.setZoom(0.5);
                      }
                    ),
                    FlatButton(
                      color: Colors.blue,
                      child: Text("zoom x1", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        await CamerawesomePlugin.setZoom(0.01);
                      }
                    ),
                  ],
                ),
              )
            ],
          );
          },
        )
      );
  }


  _takePhoto() {

  }

  _selectBestSize() {
    int screenWidth = MediaQuery.of(context).size.width.toInt();
    int screenHeight = MediaQuery.of(context).size.height.toInt();
    double screenRatio = screenWidth / screenHeight;

    camerasSizes.sort((a,b) => a.width > b.width ? -1 : 1);
//    camerasSizes.forEach((element) {print("- ${element.width}/${element.height}");});
    bestSize = camerasSizes.first;
    // TODO select by ratio
    // TODO or use predefined from Android
    print("----------------------------------");
    print("screen screenWidth: $screenWidth");
    print("screen screenHeight: $screenHeight");
    print("screen ratio: $screenRatio");
    print("bestSize: ${bestSize.width}/${bestSize.height} => ${bestSize.width / bestSize.height}");
    print("----------------------------------");

    final size = MediaQuery.of(context).size;
    bestSizeRatio = bestSize.height / bestSize.width;
    scale = bestSizeRatio / size.aspectRatio;
    if (bestSizeRatio < size.aspectRatio) {
      scale = 1 / scale;
    }
    print("rescaling : $scale");
  }

}