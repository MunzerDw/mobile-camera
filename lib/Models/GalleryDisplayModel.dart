import 'package:App/Models/GalleryModel.dart';
import 'package:flutter/cupertino.dart';

class GalleryDisplayModel extends ChangeNotifier {
  List<String> selectedImages;
  bool editing;
  GalleryModel selectedGallery;
  GalleryModel currentGallery;

  GalleryDisplayModel() {
    this.editing = false;
    this.selectedImages = List<String>();
  }

  void toogleEditing() {
    this.editing = !this.editing;
    if (!editing) {
      this.selectedImages = List<String>();
    }
    notifyListeners();
  }

  void selectImage(String path) {
    this.selectedImages.add(path);
    notifyListeners();
  }

  void deselectImage(String path) {
    this.selectedImages.remove(path);
    notifyListeners();
  }

  void selectGallery(GalleryModel gallery) {
    this.selectedGallery = gallery;
    notifyListeners();
  }

  void close() {
    this.editing = false;
    this.selectedImages = List<String>();
    this.selectedGallery = null;
    this.currentGallery = null;
  }

  void open(GalleryModel gallery) {
    this.currentGallery = gallery;
    notifyListeners();
  }

  void setEditing(bool val) {
    this.editing = val;
    notifyListeners();
  }

  void clearSelectedImages() {
    this.selectedImages = List<String>();
    notifyListeners();
  }

  void setSelectedImages(List<String> images) {
    this.selectedImages = images;
    notifyListeners();
  }

  void selectAll() {
    this.selectedImages = this.currentGallery.images;
    notifyListeners();
  }
}
