import 'dart:async';
import 'dart:io';
import 'package:App/Pages/ImageDisplay/ImageDisplay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import "package:flutter_svg/flutter_svg.dart";

import '../../Storage.dart';

class GalleryDisplay extends StatefulWidget {
  final String title;
  final Function updateTotolImagesNumber;
  GalleryDisplay({@required this.title, this.updateTotolImagesNumber});

  @override
  _GalleryDisplayState createState() => _GalleryDisplayState();
}

class _GalleryDisplayState extends State<GalleryDisplay> {
  List<String> images = List<String>();
  bool editing;

  Future<bool> _deleteImage(int index) async {
    if (await Storage.removeImage(images.elementAt(index))) {
      setState(() {
        images.removeAt(index);
      });
      widget.updateTotolImagesNumber();
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    Storage.getImages(widget.title).then((value) {
      // galleries = [RandomString(4), RandomString(5)];
      setState(() {
        images = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(1, 60, 1, 80),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 70),
                  child: Stack(
                    //SvgPicture.asset('assets/wave.svg')
                    children: <Widget>[
                      Center(
                          child: Column(
                        children: <Widget>[
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 30.0),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          Text(
                            this.images.length.toString() + " images",
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 15.0),
                          )
                        ],
                      )),
                      // Container(
                      //   color: Colors.red,
                      //   child: SvgPicture.asset('assets/wave.svg'),
                      // ),
                    ],
                  ),
                ),
                images.length != 0
                    ? GridView.count(
                        shrinkWrap: true,
                        padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                        // Create a grid with 2 columns. If you change the scrollDirection to
                        // horizontal, this produces 2 rows.
                        crossAxisCount: 4,
                        // Generate 100 widgets that display their index in the List.
                        children: List.generate(this.images.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageDisplay(
                                    index: index,
                                    gallery: widget.title,
                                    deleteImageFromGallery: this._deleteImage,
                                    imagesFromParent: this.images,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.all(1),
                              height: 120.0,
                              width: 120.0,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          FileImage(File(this.images[index])),
                                      fit: BoxFit.cover)),
                            ),
                          );
                        }),
                      )
                    : Center()
              ],
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 60, 0, 0),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      iconSize: 25,
                      icon: Icon(Icons.arrow_back_ios),
                    )
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
