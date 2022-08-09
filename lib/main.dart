import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fruit_detect/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isImageLoaded = false;
  bool modelLoaded = false;
  File? pickedImage;
  double? confidence;
  String? label;

  @override
  void initState() {
    super.initState();
    loadModel();
  }



  void loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    ).onError(
      (error, stackTrace) {
        print(error);
      },
    ).then(
      (value) {
        setState(() {
          modelLoaded = true;
        });
      },
    );
  }

  grabImage(ImageSource source) async {
    var tempStore = await ImagePicker().pickImage(source: source);
    setState(() {
      if (tempStore != null) {
        pickedImage = File(tempStore.path);
        isImageLoaded = true;
        applyModelOnImage(pickedImage!);
      } else {
        isImageLoaded = false;
        print('Please select an Image to test');
      }
    });
  }

  applyModelOnImage(File file) async {
    var res = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.001,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      confidence = res![0]['confidence'] * 100;
      label = res[0]['label'].toString().split(" ")[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   appBar: AppBar(        title: const Text('Cat Dog Recognizer'),      ),
      body: Center(
        child: Container(
          color: Color(0xFFD32F2F),
          /*  decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFD32F2F),
              Color(0xFFF44336),
            ],
          )),
        */
          child: modelLoaded
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    isImageLoaded
                        ? Column(
                            children: [
                              const SizedBox(height: 50),
                              SizedBox(
                                height: 250,
                                width: 500,
                                child: isImageLoaded
                                    ? Image.file(
                                        pickedImage!,
                                        fit: BoxFit.contain,
                                      )
                                    : const Text(
                                        'Please select an Image to test',
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                              SizedBox(height: 15,),
                              Text(
                                textAlign: TextAlign.center,
                                'الفاكهة هي $label\n %نسبة التطابق هي ${confidence?.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 236, 234, 234),
                                   fontFamily: 'jannah',
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                fontFamily: 'jannah',
                                fontSize: 32,
                                color: Color.fromARGB(255, 226, 226, 226),
                                fontWeight: FontWeight.bold,
                              ),
                              child: AnimatedTextKit(
                                repeatForever: true,
                                isRepeatingAnimation: true,
                                animatedTexts: [
                                  FadeAnimatedText('أختر صورة'),
                                  FadeAnimatedText('من الهاتف'),
                                  FadeAnimatedText('او قم بالتقاط صورة'),
                                ],
                              ),
                            ),
                          ),

                    /*
                    Text(
                        'Cat Dog Recognizer model is loaded\nPlease select an Image to test',
                        textAlign: TextAlign.center,
                      ),*/
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              grabImage(ImageSource.camera);
            },
            tooltip: 'Camera',
            child: const Icon(IconBroken.Camera),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              grabImage(ImageSource.gallery);
            },
            tooltip: 'Gallery',
            child: const Icon(IconBroken.Image_2),
          ),
        ],
      ),
    );
  }
}
