import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class TestPath extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const TestPath({Key? key, required this.cameras}) : super(key: key);

  @override
  State<TestPath> createState() => _TestPathState();
}

class _TestPathState extends State<TestPath> {
  CameraController? controller;
  String date = DateFormat('dd/MM/yy – kk:mm:ss').format(DateTime.now());
  String statusText = "Start Server";
  dynamic content;
  String html = '';
  String url = '';
  File f = File('');
  bool takepictures = true;
  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras![0], ResolutionPreset.low);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        controller!.setFlashMode(FlashMode.off);
      });
    });
  }

  void timerPeriodic() {
    Timer.periodic(const Duration(milliseconds: 200),
        (Timer t) => takepictures ? takePic() : null);
  }

  void takePic() async {
    setState(() {
      date = DateTime.now().toString();
    });
    XFile image = await controller!.takePicture();
    /* final byteData = await image.readAsBytes();
    final directory =
        (await getExternalStorageDirectories(type: StorageDirectory.downloads))!
            .first;
    File file = File("${directory.path}/$date.png");
    await file2.writeAsBytes(byteData.buffer
     .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes)); // stores image files as jpeg in the path provided by the directory*/
    setState(() {
      url = image.path;
      f = File(url);
      content = base64Encode(f.readAsBytesSync());
      html = ''' <!doctype html>s
<html>
  <head>
    <title>This is the title of the webpage!</title>
     <meta http-equiv="refresh" content="1">
  </head>
  <body>
    <p>This is an example paragraph. Anything in the <strong>body</strong> tag will appear on the page, just like this <strong>p</strong> tag and its contents.</p>
  <img src="data:image/jpeg;base64,$content" >
  </body>
</html>''';
    });
    await controller!.takePicture().then((res) => {takePic()});
  }

  startServer() async {
    setState(() {
      statusText = "Starting server on Port : 8080";
    });
    var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);

    f = url != '' ? File(url) : File('');
    content = url != '' ? base64Encode(f.readAsBytesSync()) : 'text';
    html = ''' <!doctype html>s
<html>
  <head>
    <title>This is the title of the webpage!</title>
     <meta http-equiv="refresh" content="0.5">
  </head>
  <body>
    <p>mjprg mobile camera </p>
  </body>
</html>''';
    await for (var request in server) {
      request.response
        ..headers.set("Content-Type", "text/html; charset=utf-8")
        ..write(html)
        ..close();
    }
    setState(() {
      statusText = "Server running on IP : " +
          server.address.toString() +
          " On Port : " +
          server.port.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              takePic();
              startServer();
            },
            child: Text(statusText),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                controller!.dispose();
                url = '';
                takepictures = false;
                exit(0);
              });
            },
            child: const Text('Stop server'),
          ),
          Container(
            child: url != '' ? Image.file(File(url)) : const Text('image '),
          )
        ],
      ),
    ));
  }
}
