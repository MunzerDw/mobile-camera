import 'package:App/Models/GalleriesModel.dart';
import 'package:App/Models/GalleryModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Center(
                child: Container(
              padding: EdgeInsets.fromLTRB(20, 100, 20, 100),
              child: Text(
                "Settings",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 40.0,
                    color: Colors.black),
              ),
            )),
            DefaultGallery()
          ],
        ),
      ),
    );
  }
}

class DefaultGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.only(left: 20, top: 40, bottom: 40, right: 30),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Default Gallery",
              style: TextStyle(fontSize: 17, color: Colors.grey[700]),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Consumer<GalleriesModel>(
                  builder: (context, galleriesModel, child) {
                return DropdownButton<String>(
                  items: galleriesModel.galleries.map((GalleryModel value) {
                    return DropdownMenuItem<String>(
                      value: value.name,
                      child: Text(value.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    galleriesModel.setdefaultGallery(value);
                  },
                  underline: SizedBox(),
                  value: galleriesModel.defaultGallery == null
                      ? ""
                      : galleriesModel.defaultGallery.name,
                  elevation: 2,
                  style: TextStyle(color: Colors.grey[600], fontSize: 17),
                  iconSize: 40.0,
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
