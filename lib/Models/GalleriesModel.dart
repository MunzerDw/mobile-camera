// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:App/Components/GalleriesCard/GalleriesCard.dart';
import 'package:App/Storage.dart';
import 'package:flutter/foundation.dart';
import 'GalleryModel.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:camera/camera.dart';

class GalleriesModel extends ChangeNotifier {
  List<GalleryModel> galleries = [];
  GlobalKey<AnimatedListState> listKey = GlobalKey();
  GalleryModel defaultGallery;
  GalleryModel selectedGallery;
  PageController pageViewController;
  List<CameraDescription> cameras;
  CameraDescription camera;
  CameraController cameraController;
  Future<void> initializeControllerFuture;

  GalleriesModel() {
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
    var temp = await Storage.getGalleries();
    this.galleries = temp.map((f) {
      return GalleryModel(f);
    }).toList();
    await updateDefaultGallery();
    this.selectedGallery = this.defaultGallery;
    notifyListeners();
  }

  void goToCamera(String gallery) {
    this.setSelectedGallery(gallery);
    this.pageViewController.animateToPage(1,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  Future<void> setdefaultGallery(String gallery) {
    return SharedPreferences.getInstance().then((onValue) {
      onValue.setString('defaultGallery', gallery);
      try {
        this.defaultGallery =
            this.galleries.firstWhere((item) => item.name == gallery);
      } catch (e) {}
      notifyListeners();
    });
  }

  Future<void> updateDefaultGallery() {
    return SharedPreferences.getInstance().then((pref) {
      if (pref.getString('defaultGallery') != null) {
        GalleryModel temp;
        try {
          temp = this.galleries.firstWhere((item) {
            return item.name == pref.getString('defaultGallery');
          });
          pref.setString('defaultGallery', pref.getString('defaultGallery'));
          this.defaultGallery = temp;
        } catch (e) {
          if (this.galleries.isEmpty) {
            pref.setString('defaultGallery', null);
            this.defaultGallery = temp;
          } else {
            pref.setString('defaultGallery', this.galleries[0].name);
            this.defaultGallery = this.galleries[0];
          }
        }
      }
      if (pref.getString('defaultGallery') == null &&
          this.galleries.isNotEmpty) {
        pref.setString('defaultGallery', this.galleries[0].name);
        this.defaultGallery = this.galleries[0];
      }
    });
  }

  void setSelectedGallery(String gallery) {
    try {
      this.selectedGallery =
          this.galleries.firstWhere((item) => item.name == gallery);
      notifyListeners();
    } catch (e) {}
  }

  void updateSelectedGallery() {
    if (this.galleries.isNotEmpty &&
        !this.galleries.contains(this.selectedGallery)) {
      this.selectedGallery = this.defaultGallery;
    }
  }

  List<GalleryModel> getGalleries() {
    return galleries;
  }

  Widget buildItem(
      BuildContext context, int index, String item, Animation animation) {
    return index != 0
        ? Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: SlideTransition(
              // opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: GalleriesCard(key: UniqueKey(), title: item),
            ),
          )
        : Center(
            child: Container(
            padding: EdgeInsets.fromLTRB(20, 100, 20, 100),
            child: Text(
              "Galleries",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 40.0,
                  color: Colors.black),
            ),
          ));
  }

  GalleryModel getGallery(String name) {
    return this.galleries.firstWhere((test) => test.name == name);
  }

  Future<bool> add(String newGallery) {
    if (newGallery.isEmpty) {
      return Future<bool>.value(false);
    }
    for (var gallery in this.galleries) {
      if (gallery.name == newGallery) {
        return Future<bool>.value(false);
      }
    }
    return Storage.addGallery(newGallery).then((onValue) async {
      this.galleries.add(GalleryModel(newGallery));
      if (listKey.currentState != null) {
        listKey.currentState.insertItem(this.galleries.length);
      }
      await updateDefaultGallery();
      updateSelectedGallery();
      notifyListeners();
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  Future<bool> remove(String gallery) {
    int index = this.galleries.indexOf(this.galleries.firstWhere((item) {
          return item.name == gallery;
        }));
    return Storage.removeGallery(gallery).then((onValue) {
      listKey.currentState.removeItem(
        index + 1,
        (BuildContext context, Animation animation) =>
            buildItem(context, index + 1, gallery, animation),
        duration: const Duration(milliseconds: 250),
      );
      Future.delayed(const Duration(milliseconds: 250), () async {
        this.galleries.remove(this.galleries.firstWhere((item) {
              return item.name == gallery;
            }));
        await updateDefaultGallery();
        updateSelectedGallery();
        notifyListeners();
      });
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  Future<bool> moveImages(String from, String to, List<String> images) async {
    GalleryModel fromGallery =
        this.galleries.firstWhere((test) => test.name == from);
    GalleryModel toGallery =
        this.galleries.firstWhere((test) => test.name == to);
    return Storage.moveImages(from, to, images).then((onValue) async {
      if (onValue) {
        toGallery.addImages(images);
        await fromGallery.removeImages(images);
        notifyListeners();
      }
      return onValue;
    });
  }

  Future<bool> editGalleryName(String gallery, String newName) {
    return this
        .galleries
        .firstWhere((item) {
          return item.name == gallery;
        })
        .editGalleryName(newName)
        .then((onValue) {
          if (onValue) {
            notifyListeners();
          }
          return onValue;
        });
  }

  Future<bool> removeImages(GalleryModel gallery, List<String> paths) async {
    return this
        .getGallery(gallery.name)
        .removeImages(List.from(paths))
        .then((onValue) {
      if (onValue) {
        notifyListeners();
      }
      return onValue;
    });
  }
}
