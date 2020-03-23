import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:App/Components/AddGallery/AddGallery.dart';
import 'package:App/Pages/Blink/Blink.dart';
import 'package:App/Pages/Galleries/Galleries.dart';
import 'package:App/Pages/ImageDisplay/ImageDisplay.dart';
import 'package:App/Storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class Camera extends StatefulWidget {
  final List<String> galleries;
  final CameraDescription camera;
  final CameraController cameraController;
  final Future<void> initializeControllerFuture;
  final Function addGallery;
  final Function setSelectedGalleryIndex;
  final int selectedGalleryIndex;
  final PageController pageViewController;
  Camera(
      {@required this.camera,
      @required this.cameraController,
      @required this.initializeControllerFuture,
      @required this.galleries,
      @required this.addGallery,
      @required this.selectedGalleryIndex,
      @required this.setSelectedGalleryIndex,
      @required this.pageViewController});

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  Map<String, String> imagesMap = Map<String, String>();
  List<String> images = List<String>();

  @override
  void initState() {
    images = imagesMap.keys.toList();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black87,
      ),
    );
    super.initState();
  }

  Future<bool> deleteImage(int index) async {
    if (await Storage.removeImage(images.elementAt(index))) {
      setState(() {
        imagesMap.remove(images.elementAt(index));
        images.removeAt(index);
      });
      return true;
    } else {
      return false;
    }
  }

  void addImage(String image) {
    setState(() {
      imagesMap.putIfAbsent(
          image, () => widget.galleries[widget.selectedGalleryIndex]);
      images = imagesMap.keys.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.black,
              child: Container(
                alignment: Alignment.bottomCenter,
                padding:
                    EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    widget.galleries.length != 0
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: DropdownButton<String>(
                              items: widget.galleries.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  widget.setSelectedGalleryIndex(
                                      widget.galleries.indexOf(value));
                                });
                              },
                              underline: SizedBox(),
                              value: widget.selectedGalleryIndex >=
                                      widget.galleries.length
                                  ? "Empty"
                                  : widget
                                      .galleries[widget.selectedGalleryIndex],
                              elevation: 2,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 20),
                              iconSize: 40.0,
                            ),
                          )
                        : RaisedButton(
                            color: Colors.white,
                            clipBehavior: Clip.hardEdge,
                            elevation: 3,
                            shape: CircleBorder(),
                            child: IconButton(
                                color: Colors.blue[800],
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AddGallery(
                                            addGallery: widget.addGallery,
                                          ));
                                }),
                            onPressed: () {},
                          ),
                    this.images.length <= 0
                        ? Container()
                        : FittedBox(
                            child: MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageDisplay(
                                    index: this.images.isEmpty
                                        ? 0
                                        : this.images.length - 1,
                                    deleteImageFromGallery: this.deleteImage,
                                    imagesFromParent: this.images,
                                  ),
                                ),
                              );
                            },
                            child: this.images.length <= 0
                                ? null
                                : Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                            image: FileImage(
                                                File(this.images.last)),
                                            fit: BoxFit.cover))),
                          ))
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<void>(
            future: widget.initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  width: screenWidth,
                  height: screenWidth * 1.4,
                  //Kein plan wieso hier ein border soll.. voll komisch, da ist sonst ein anderer weisser border
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black, width: 0))),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Container(
                      width: screenWidth,
                      height: screenWidth /
                          widget.cameraController.value.aspectRatio,
                      child: CameraPreview(
                          widget.cameraController), // this is my CameraPreview
                    ),
                  ),
                );
              } else {
                // Otherwise, display a loading indicator
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Container(
              padding:
                  EdgeInsets.only(top: 25, bottom: 25, left: 35, right: 35),
              alignment: Alignment.center,
              color: Colors.black,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.folder,
                      size: 35,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      widget.pageViewController.animateToPage(0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                  ),
                  Container(
                      width: 86,
                      height: 86,
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey[400], width: 5.0)),
                      child: RaisedButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(86),
                        ),
                        color: Colors.white,
                        onPressed: () async {
                          if (widget.galleries.length > 0) {
                            final Directory _appDocDir =
                                await getApplicationDocumentsDirectory();
                            String path = _appDocDir.path +
                                '/galleries/' +
                                widget.galleries[widget.selectedGalleryIndex] +
                                '/${DateTime.now()}.png';
                            try {
                              await widget.initializeControllerFuture;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Blink(),
                                ),
                              );
                              Future.delayed(Duration(milliseconds: 150), () {
                                Navigator.pop(context);
                              });
                              await widget.cameraController.takePicture(path);
                              this.addImage(path);
                            } catch (e) {
                              print(e);
                            }
                          } else {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                    title: Column(
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 4.0,
                                                color: Colors.orangeAccent),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.all(20),
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          child: Icon(
                                            Icons.warning,
                                            color: Colors.orangeAccent,
                                            size: 50,
                                          ),
                                        ),
                                        Text(
                                          "Please add a gallery first",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.orangeAccent),
                                        ),
                                      ],
                                    ),
                                    content: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Container(
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          5.0)),
                                              child: Text(
                                                "cancel",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              color: Colors.grey,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                          Container(
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          5.0)),
                                              child: Text(
                                                "add",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              color: Colors.green,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                showDialog(
                                                    context: context,
                                                    builder: (_) => AddGallery(
                                                          addGallery:
                                                              widget.addGallery,
                                                        ));
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0))));
                          }
                        },
                      )),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 35,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      widget.pageViewController.animateToPage(2,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
