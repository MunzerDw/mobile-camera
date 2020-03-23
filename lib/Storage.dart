import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import "package:path_provider/path_provider.dart";
import 'package:camera/camera.dart';
import 'Pages/Camera/Camera.dart';

class Storage {
  static Future<List<String>> getGalleries() async {
    List<String> result = List<String>();

    Completer<List<String>> completer = new Completer();
    final Directory _appDocDir = await getApplicationDocumentsDirectory();

    Directory(_appDocDir.path + '/galleries')
        .list(recursive: false, followLinks: false)
        .listen((FileSystemEntity entity) {
      result.add(entity.path.split("/")[entity.path.split("/").length - 1]);
    }).onDone(() {
      completer.complete(result);
    });

    return completer.future;
  }

  static Future<bool> addGallery(String gallery) async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();

    return Directory(_appDocDir.path + '/galleries/' + gallery)
        .create(recursive: true)
        .then((Directory directory) {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  static Future<bool> removeGallery(String gallery) async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();

    return Directory(_appDocDir.path + '/galleries/' + gallery)
        .delete(recursive: true)
        .then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  static Future<List<String>> getImages(String gallery) async {
    List<String> result = List<String>();

    Completer<List<String>> completer = new Completer();
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    Directory(_appDocDir.path + "/galleries/" + gallery)
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      result.add(entity.path);
    }).onDone(() {
      completer.complete(result);
    });

    return completer.future;
  }

  static Future<bool> copyImage(File image, String newPath) async {
    return image.copy(newPath).then((onValue) {
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  static Future<bool> removeImage(String image) async {
    return File(image).delete(recursive: true).then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  static Future<bool> editGalleryName(
      String oldGallery, String newGallery) async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    List<String> currentGalleries = await Storage.getGalleries();
    if (!currentGalleries.contains(oldGallery)) {
      return false;
    }

    List<File> imagesToMove = List<File>();
    Directory(_appDocDir.path + "/galleries/" + oldGallery)
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      imagesToMove.add(entity);
    });

    if (!(await Storage.addGallery(newGallery))) {
      return false;
    }

    imagesToMove.forEach((image) async {
      String newPath = image.path.replaceAll(oldGallery, newGallery);
      if (!(await Storage.copyImage(image, newPath))) {
        return false;
      }
    });

    if (!(await Storage.removeGallery(oldGallery))) {
      return false;
    }
    return true;
  }
}
