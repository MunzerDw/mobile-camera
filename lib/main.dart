import 'dart:async';
import 'dart:math';
import 'package:App/Pages/Galleries/Galleries.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'Pages/Camera/Camera.dart';
import 'Pages/Settings/Settings.dart';
import "Storage.dart";
import "package:shared_preferences/shared_preferences.dart";

// void main() => runApp(MyApp());
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(
    MaterialApp(title: 'Camera App', home: Home(cameras: cameras)),
  );
}

class Home extends StatefulWidget {
  final List<CameraDescription> cameras;
  Home({@required this.cameras});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> galleries = List<String>();
  int selectedGalleryIndex;
  int defaultGalleryIndex;
  PageController pageViewController = PageController(initialPage: 1);
  CameraDescription camera;
  CameraController cameraController;
  Future<void> _initializeControllerFuture;

  Future<bool> addGalleryFromHome(String gallery) async {
    if (galleries.contains(gallery) || gallery == "") {
      return false;
    }
    if (await Storage.addGallery(gallery)) {
      setState(() {
        galleries.add(gallery);
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteGalleryFromHome(String gallery) async {
    if (await Storage.removeGallery(gallery)) {
      setState(() {
        galleries.removeAt(galleries.indexOf(gallery));
      });

      (this.selectedGalleryIndex != null && this.selectedGalleryIndex > 0)
          ? this.setSelectedGalleryIndex((this.selectedGalleryIndex - 1) < 0
              ? 0
              : this.selectedGalleryIndex - 1)
          : this.setSelectedGalleryIndex(this.selectedGalleryIndex);

      (this.defaultGalleryIndex > 0)
          ? this.setDefaultGalleryIndex((this.defaultGalleryIndex - 1) < 0
              ? 0
              : this.defaultGalleryIndex - 1)
          : this.setDefaultGalleryIndex(this.defaultGalleryIndex);
      return true;
    } else {
      return false;
    }
  }

  void setDefaultGalleryIndex(int index) async {
    setState(() {
      defaultGalleryIndex = index;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('defaultGalleryIndex', defaultGalleryIndex);
  }

  void setSelectedGalleryIndex(int index) {
    setState(() {
      selectedGalleryIndex = index;
    });
  }

  void goToCamera(String gallery) {
    this.setSelectedGalleryIndex(this.galleries.indexOf(gallery));
    this.pageViewController.animateToPage(1,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  void initState() {
    camera = widget.cameras[0];
    cameraController = CameraController(
      this.camera,
      ResolutionPreset.max,
    );
    _initializeControllerFuture = cameraController.initialize();
    super.initState();
    Storage.getGalleries().then((value) async {
      // galleries = [RandomString(4), RandomString(5)];
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('defaultGalleryIndex') == null) {
        this.setDefaultGalleryIndex(0);
      } else if (prefs.getInt('defaultGalleryIndex') > (value.length - 1)) {
        this.setDefaultGalleryIndex(0);
      } else {
        this.setDefaultGalleryIndex(prefs.getInt('defaultGalleryIndex'));
      }
      setState(() {
        galleries = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //State of the pages will always be recreated once returned to the page
      child: PageView(
        physics: BouncingScrollPhysics(),
        controller: pageViewController,
        children: <Widget>[
          Galleries(
              galleries: this.galleries,
              addGalleryFromHome: this.addGalleryFromHome,
              deleteGalleryFromHome: this.deleteGalleryFromHome,
              goToCamera: this.goToCamera),
          Camera(
            camera: widget.cameras[0],
            cameraController: this.cameraController,
            initializeControllerFuture: this._initializeControllerFuture,
            galleries: this.galleries,
            addGallery: this.addGalleryFromHome,
            setSelectedGalleryIndex: this.setSelectedGalleryIndex,
            selectedGalleryIndex: this.selectedGalleryIndex == null
                ? this.defaultGalleryIndex
                : this.selectedGalleryIndex,
            pageViewController: this.pageViewController,
          ),
          Settings(
            galleries: this.galleries,
            defaultGalleryIndex: this.defaultGalleryIndex,
            setDefaultGalleryIndex: this.setDefaultGalleryIndex,
          ),
        ],
      ),
    );
  }
}
