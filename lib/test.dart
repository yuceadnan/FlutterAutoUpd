import 'dart:io';
import 'package:flutter/material.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:package_info/package_info.dart';
import 'Models/ApiResult.dart';

void main() => runApp(new TestApp());

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => new _TestAppState();
}

class _TestAppState extends State<TestApp> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  String _message = "";
  String _progress = "-";
  bool _showVersionCheck = true;
  bool _showUpdateBtn = false;
  String _localApkFilePath = '';
  String _baseUrl =
      "service bae url";
  String _sourceApkUrl = "";
  final Dio _dio = Dio();
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      _sourceApkUrl = _baseUrl + "/Download/${_packageInfo.packageName}.apk";
    });
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      var downloadDirectory = await DownloadsPathProvider.downloadsDirectory;
      _localApkFilePath = downloadDirectory.path;
      return await DownloadsPathProvider.downloadsDirectory;
    }

    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _requestPermissions() async {
    var permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
    }

    return permission == PermissionStatus.granted;
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future<void> _startDownload(String savePath) async {
    try {
      await _dio.download(_sourceApkUrl, savePath,
          onReceiveProgress: _onReceiveProgress);
      updateApk();
    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<void> _download() async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      final savePath = path.join(dir.path, _packageInfo.packageName);
      setState(() {
        _showUpdateBtn = false;
      });
      await _startDownload(savePath);
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  Future<bool> _checkVersion() async {
    try {
      Response response = await Dio().get(
          _baseUrl + "/Lisans/CheckVersion?version=${_packageInfo.version}");
      if (response != null && response.statusCode == 200) {
        var res = ResultModel.fromJson(response.data);
        setState(() {
          _showVersionCheck = res.status == 1 ? false : true;
          _showUpdateBtn = res.status == 1 ? true : false;
        });
        _message = res.message;
        return res.status == 1;
      } else
        return false;
    } catch (ex) {
      print(ex.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // The following will print 'null'
    print(MaterialLocalizations.of(context));
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Auto Update App'),
          ),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text('Download progress:', style: TextStyle(fontSize: 18)),
              Text('$_progress', style: TextStyle(fontSize: 25, height: 2)),
              Text('Current Version Name :${_packageInfo.version}',
                  style: TextStyle(fontSize: 18, height: 3)),
              Text('Current Version Code :${_packageInfo.buildNumber}',
                  style: TextStyle(fontSize: 18, height: 2)),
              Visibility(
                  visible: _showVersionCheck,
                  child: RaisedButton(
                      color: Colors.orange,
                      textColor: Colors.white,
                      onPressed: () async {
                        var res = await _checkVersion();
                      },
                      child: Text('Güncellemeleri Kontrol Et',
                          style: TextStyle(fontSize: 18)))),
              Text(_message,
                  style:
                      TextStyle(fontSize: 20, height: 3, color: Colors.green)),
              Visibility(
                  visible: _showUpdateBtn,
                  child: RaisedButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      onPressed: () {
                        _download();
                      },
                      child: Text('Güncelle', style: TextStyle(fontSize: 18))))
            ],
          ))),
    );
  }

  void updateApk() async {
    if (_localApkFilePath.isEmpty) {
      print('make sure the apk file is set');
      return;
    }
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      InstallPlugin.installApk(
              _localApkFilePath + "/" + _packageInfo.packageName,
              _packageInfo.packageName)
          .then((result) {
        print('install apk $result');
        setState(() {
          _showVersionCheck = true;
          _message = "";
          _progress = "-";
        });
      }).catchError((error) {
        print('install apk error: $error');
      });
    } else {
      print('Permission request fail!');
    }
  }
}
