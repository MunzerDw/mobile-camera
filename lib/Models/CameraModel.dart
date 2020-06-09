import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';

class CameraModel extends ChangeNotifier {
  PageController pageViewController;
  List<CameraDescription> cameras;
  CameraDescription camera;
  CameraController cameraController;
  Future<void> initializeControllerFuture;

  CameraModel() {
    this.pageViewController = PageController(initialPage: 1);
    this.initAsync();
  }

  void initAsync() async {
    this.cameras = await availableCameras();
    this.camera = this.cameras[0];
    this.cameraController = CameraController(
      this.cameras[0],
      ResolutionPreset.max,
    );
    this.initializeControllerFuture = cameraController.initialize();
    notifyListeners();
  }

  void goToCamera(String gallery) {
    this.pageViewController.animateToPage(1,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }
}
