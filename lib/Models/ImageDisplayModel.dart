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

  void showTopBar() {
    this.topBarVisible = true;
    notifyListeners();
  }

  void clear() {
    this.imagesMap.clear();
    notifyListeners();
  }

  bool isEmpty() {
    for (var list in this.imagesMap.values) {
      if (list.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  void addImage(GalleryModel gallery, String image) {
    if (imagesMap.containsKey(gallery)) {
      imagesMap[gallery].add(image);
    } else {
      imagesMap.putIfAbsent(gallery, () => [image]);
    }
    notifyListeners();
  }

  Future<bool> removeImage(GalleryModel gallery, String image) {
    return gallery.removeImage(image).then((onValue) async {
      if (!this.isEmpty()) {
        this.pageViewController.animateToPage(
              this.currentImageIndex == 0 ? 0 : this.currentImageIndex - 1,
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
            );
      }
      await Future.delayed(Duration(milliseconds: 200), () {
        if (imagesMap.containsKey(gallery)) {
          imagesMap[gallery].remove(image);
        }
      });
      notifyListeners();
      return true;
    });
  }

  void removeImages(GalleryModel gallery, List<String> images) {
    for (var path in images) {
      if (imagesMap.containsKey(gallery)) {
        imagesMap[gallery].remove(path);
      }
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

  Future<bool> removeCurrentImage() {
    String path = this.getCurrentImage();
    GalleryModel gallery = this.imagesMap.keys.firstWhere((item) {
      return item.images.contains(path);
    });
    return this.removeImage(gallery, path);
  }

  String getCurrentImage() {
    int counter = this.currentImageIndex;
    String path;
    outer:
    for (var list in this.imagesMap.values) {
      for (var image in list) {
        if (counter == 0) {
          path = image;
          break outer;
        }
        counter--;
      }
    }
    return path;
  }

  int getLastIndex() {
    int result = 0;
    for (var list in this.imagesMap.values) {
      result += list.length;
    }
    return result - 1;
  }

  String getLastImage() {
    String result;
    for (var list in this.imagesMap.values) {
      if (list.isNotEmpty) {
        result = list.last;
      }
    }
    // notifyListeners();
    return result;
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

  List<String> getAllImages() {
    return this.combineLists(this.imagesMap.values.toList());
  }
}
