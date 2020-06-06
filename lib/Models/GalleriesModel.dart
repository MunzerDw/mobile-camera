// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:App/Components/GalleriesCard/GalleriesCard.dart';
import 'package:App/Storage.dart';
import 'package:flutter/foundation.dart';
import 'GalleryModel.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";

class GalleriesModel extends ChangeNotifier {
  List<GalleryModel> galleries = [];
  GlobalKey<AnimatedListState> listKey = GlobalKey();
  GalleryModel defaultGallery;
  GalleryModel selectedGallery;

  GalleriesModel() {
    this.init();
  }

  void init() async {
    var temp = await Storage.getGalleries();
    this.galleries = temp.map((f) {
      return GalleryModel(f);
    }).toList();
    await updateDefaultGallery();
    this.selectedGallery = this.defaultGallery;
    notifyListeners();
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
              child: GalleriesCard(
                key: UniqueKey(),
                title: item,
                goToCamera: null,
              ),
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
    try {
      return this.galleries.firstWhere((test) => test.name == name);
    } catch (e) {}
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

    notifyListeners();
    return await toGallery.addImages(images)
        ? (await fromGallery.removeImages(images) ? true : false)
        : false;
  }
}
