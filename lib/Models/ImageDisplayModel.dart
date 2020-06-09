import 'package:App/Models/GalleryModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';

class ImageDisplayModel extends ChangeNotifier {
  PageController pageViewController;
  PhotoViewControllerBase photoViewController;
  PhotoViewScaleStateController scaleStateController;
  bool zoomedOut = true;
  int currentImageIndex;
  bool topBarVisible = true;
  Map<GalleryModel, List<String>> imagesMap = Map<GalleryModel, List<String>>();

  ImageDisplayModel() {
    this.currentImageIndex = 0;
    this.photoViewController = PhotoViewController();
    this.scaleStateController = PhotoViewScaleStateController();
    this.pageViewController = PageController(initialPage: currentImageIndex);
  }

  void toogleTopBar() {
    this.topBarVisible = !this.topBarVisible;
    notifyListeners();
  }

  void addImage(GalleryModel gallery, String image) {
    if (imagesMap.containsKey(gallery)) {
      imagesMap[gallery].add(image);
    } else {
      imagesMap.putIfAbsent(gallery, () => [image]);
    }
    notifyListeners();
  }

  List<String> combineLists(List<List<String>> lists) {
    List<String> result = List<String>();
    for (var list in lists) {
      result.addAll(list);
    }
    return result;
  }

  Future<bool> removeImage(GalleryModel gallery, String image) {
    return gallery.removeImage(image).then((onValue) {
      if (imagesMap.containsKey(gallery)) {
        imagesMap[gallery].remove(image);
      }

      if (this.combineLists(this.imagesMap.values.toList()).isNotEmpty) {
        this.pageViewController.animateToPage(
              this.currentImageIndex == 0 ? 0 : this.currentImageIndex - 1,
              duration: Duration(milliseconds: 250),
              curve: Curves.ease,
            );
      }
      notifyListeners();
      return true;
    });
  }

  void addImages(GalleryModel gallery, List<String> images) {
    this.imagesMap.clear();
    for (var image in images) {
      this.addImage(gallery, image);
    }
    notifyListeners();
  }

  void setCurrentImageIndex(int i) {
    this.currentImageIndex = i;
    this.pageViewController = PageController(initialPage: currentImageIndex);
    notifyListeners();
  }

  void setZoomedOut(bool val) {
    this.zoomedOut = val;
    notifyListeners();
  }
}
