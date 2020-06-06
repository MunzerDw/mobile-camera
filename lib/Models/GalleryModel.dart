import 'package:App/Storage.dart';
import 'package:flutter/foundation.dart';

class GalleryModel extends ChangeNotifier {
  String name;
  List<String> images = [];

  GalleryModel(String name) {
    this.name = name;
    Storage.getImages(name).then((onValue) {
      this.images = onValue;
      notifyListeners();
    });
  }

  String getName() {
    return this.name;
  }

  List<String> getImages() {
    return this.images;
  }

  Future<bool> removeImage(String path) {
    return Storage.removeImage(path).then((onValue) {
      this.images.remove(path);
      notifyListeners();
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  Future<bool> addImage(String path) {
    this.images.add(path);
    return Future<bool>.value(true);
    // return Future<bool>(() => {}).then((onValue) {
    //   this.images.add(path);
    //   return true;
    // });
  }

  Future<bool> removeImages(List<String> paths) async {
    var pathsStream = new Stream.fromIterable(paths);
    await for (var path in pathsStream) {
      Storage.removeImage(path).then((onValue) {
        this.images.remove(path);
        notifyListeners();
      }).catchError((onError) {
        return false;
      });
    }
    return true;
  }

  Future<bool> addImages(List<String> paths) async {
    var pathsStream = new Stream.fromIterable(paths);
    await for (var path in pathsStream) {
      this.addImage(path).then((onValue) {
        this.images.remove(path);
        notifyListeners();
      }).catchError((onError) {
        return false;
      });
    }
    return true;
  }

  Future<bool> editGalleryName(String newName) {
    return Storage.editGalleryName(this.name, newName).then((onValue) {
      this.name = newName;
      notifyListeners();
      return true;
    }).catchError((onError) {
      return false;
    });
  }
}
