import 'dart:async';
import 'dart:math';
import 'package:App/Pages/Galleries/Galleries.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'Pages/Camera/Camera.dart';
import 'Pages/Settings/Settings.dart';
import "Storage.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:provider/provider.dart';
import './Models/GalleriesModel.dart';
import './Models/GalleryModel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    CameraGal(),
  );
}

class CameraGal extends StatelessWidget {
  const CameraGal({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GalleriesModel>(
        create: (context) => GalleriesModel(),
        child: MaterialApp(
            title: 'Camera Gal',
            initialRoute: '/',
            routes: {'/': (context) => PagesController()}));
  }
}

class PagesController extends StatelessWidget {
  const PagesController({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleriesModel>(builder:
        (BuildContext context, GalleriesModel galleriesModel, Widget child) {
      return PageView(
        physics: BouncingScrollPhysics(),
        controller: galleriesModel.pageViewController,
        children: <Widget>[
          Galleries(),
          Camera(),
          Settings(),
        ],
      );
    });
  }
}
