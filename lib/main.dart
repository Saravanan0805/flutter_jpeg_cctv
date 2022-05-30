// ignore_for_file: prefer_const_constructors, unused_import

import 'dart:io';
import 'package:cctv/dart_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(InitialScreen());
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        primarySwatch: Colors.indigo,
      ),
      home: TestPath(cameras: cameras),
      title: 'appName',
      debugShowCheckedModeBanner: false,
    );
  }
}
