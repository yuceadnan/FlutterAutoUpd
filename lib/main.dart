import 'package:flutter/material.dart';
//import 'package:update_app/update_app.dart';
import 'test.dart';

void main() => runApp(TestApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auto Update App'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('click right bottom download button download!'),
              Text('Version Name : 1.0.0'),
              Text('Version Code : 1'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: download,
          child: Icon(Icons.file_download),
        ),
      ),
    );
  }

  void download() async {
    // var name = await UpdateApp.updateApp(
    //     url: "http://192.168.2.105/flutterAppUPD/APK/app.apk",
    //     appleId: "375380948");
    // print(name);

    setState(() {});
  }
}
