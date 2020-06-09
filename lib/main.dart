import 'package:App/Models/CameraModel.dart';
import 'package:App/Models/ImageDisplayModel.dart';
import 'package:App/Pages/Galleries/Galleries.dart';
import 'package:flutter/material.dart';
import 'Models/GalleryDisplayModel.dart';
import 'Pages/Camera/Camera.dart';
import 'Pages/Settings/Settings.dart';
import 'package:provider/provider.dart';
import './Models/GalleriesModel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    CameraGal(),
  );
}

class CameraGal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GalleriesModel>(
            create: (context) => GalleriesModel()),
        ChangeNotifierProvider<CameraModel>(create: (context) => CameraModel()),
        ChangeNotifierProvider<ImageDisplayModel>(
            create: (context) => ImageDisplayModel()),
        ChangeNotifierProvider<GalleryDisplayModel>(
            create: (context) => GalleryDisplayModel())
      ],
      child: MaterialApp(
          title: 'Camera Gal',
          initialRoute: '/',
          routes: {'/': (context) => Pages()}),
    );
  }
}

class Pages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraModel>(
        builder: (BuildContext context, CameraModel cameraModel, Widget child) {
      return PageView(
        physics: BouncingScrollPhysics(),
        controller: cameraModel.pageViewController,
        children: <Widget>[
          Galleries(),
          Camera(),
          Settings(),
        ],
      );
    });
  }
}
