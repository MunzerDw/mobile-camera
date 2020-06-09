import 'dart:async';
import 'dart:io';
import 'package:App/Models/CameraModel.dart';
import 'package:App/Models/GalleriesModel.dart';
import 'package:App/Models/ImageDisplayModel.dart';
import 'package:App/Pages/ImageDisplay/ImageDisplay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import "package:flutter_svg/flutter_svg.dart";
import 'package:provider/provider.dart';
import '../../Storage.dart';

class GalleryDisplay extends StatefulWidget {
  final String title;
  GalleryDisplay({@required this.title});

  @override
  _GalleryDisplayState createState() => _GalleryDisplayState();
}

class _GalleryDisplayState extends State<GalleryDisplay> {
  List<String> selectedImages = List<String>();
  bool editing;
  String selectedGallery;

  void toogleEditing() {
    setState(() {
      editing = !this.editing;
      if (!editing) {
        this.selectedImages = List<String>();
      }
    });
  }

  void selectImage(String path) {
    setState(() {
      selectedImages.add(path);
    });
  }

  void deselectImage(String path) {
    setState(() {
      selectedImages.remove(path);
    });
  }

  @override
  void initState() {
    editing = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var galleriesModel = Provider.of<GalleriesModel>(context);
    var cameraModel = Provider.of<CameraModel>(context);
    var imageDisplayModel = Provider.of<ImageDisplayModel>(context);
    const List<Choice> choices = const <Choice>[
      const Choice(title: 'Delete', icon: Icons.delete),
      const Choice(title: 'Move', icon: Icons.reply),
    ];

    return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails dragEndDetails) {
            if (dragEndDetails.velocity.pixelsPerSecond.dx > 0) {
              Navigator.pop(context);
            }
          },
          child: Stack(
            children: <Widget>[
              ListView(
                padding: const EdgeInsets.fromLTRB(1, 60, 1, 80),
                children: <Widget>[
                  Header(
                    title: widget.title,
                  ),
                  galleriesModel.getGallery(widget.title).getImages().length !=
                          0
                      ? GridView.count(
                          shrinkWrap: true,
                          padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                          crossAxisCount: 4,
                          children: List.generate(
                              galleriesModel
                                  .getGallery(widget.title)
                                  .getImages()
                                  .length, (index) {
                            return GestureDetector(
                              onLongPress: () {
                                if (!this.editing) {
                                  this.toogleEditing();
                                  this.selectImage(galleriesModel
                                      .getGallery(widget.title)
                                      .getImages()
                                      .elementAt(index));
                                }
                              },
                              onTap: () {
                                if (!this.editing) {
                                  imageDisplayModel.setCurrentImageIndex(index);
                                  imageDisplayModel.addImages(
                                      galleriesModel.getGallery(widget.title),
                                      galleriesModel
                                          .getGallery(widget.title)
                                          .getImages());
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageDisplay(),
                                    ),
                                  ).then((onValue) {
                                    imageDisplayModel.clear();
                                    imageDisplayModel.showTopBar();
                                  });
                                } else {
                                  if (selectedImages.contains(galleriesModel
                                      .getGallery(widget.title)
                                      .getImages()
                                      .elementAt(index))) {
                                    this.deselectImage(galleriesModel
                                        .getGallery(widget.title)
                                        .getImages()
                                        .elementAt(index));
                                  } else {
                                    this.selectImage(galleriesModel
                                        .getGallery(widget.title)
                                        .getImages()
                                        .elementAt(index));
                                  }
                                }
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.all(1),
                                padding: EdgeInsets.all(5),
                                height: 120.0,
                                width: 120.0,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(File(galleriesModel
                                            .getGallery(widget.title)
                                            .getImages()[index])),
                                        fit: BoxFit.cover)),
                                child: this.editing
                                    ? Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectedImages.contains(
                                                    galleriesModel
                                                        .getGallery(
                                                            widget.title)
                                                        .getImages()
                                                        .elementAt(index))
                                                ? Colors.white
                                                : Colors.white38,
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: selectedImages.contains(
                                                galleriesModel
                                                    .getGallery(widget.title)
                                                    .getImages()
                                                    .elementAt(index))
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.black,
                                              )
                                            : Center(),
                                      )
                                    : Center(),
                              ),
                            );
                          }),
                        )
                      : Center()
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 60, left: 15, right: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      iconSize: 25,
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        this.editing
                            ? PopupMenuButton<Choice>(
                                onSelected: (value) {
                                  switch (value.title) {
                                    case "Delete":
                                      {
                                        if (this.selectedImages.length > 0) {
                                          showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                    title: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 4.0,
                                                                color: Colors
                                                                    .orangeAccent),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  20),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 20.0),
                                                          child: Icon(
                                                            Icons.warning,
                                                            color: Colors
                                                                .orangeAccent,
                                                            size: 50,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Deleting " +
                                                              widget.title,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        Text(
                                                          "Are you sure you want to delete?",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )
                                                      ],
                                                    ),
                                                    content: Container(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: <Widget>[
                                                          Container(
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      new BorderRadius
                                                                              .circular(
                                                                          5.0)),
                                                              child: Text(
                                                                "No",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              color:
                                                                  Colors.grey,
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ),
                                                          Container(
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      new BorderRadius
                                                                              .circular(
                                                                          5.0)),
                                                              child: Text(
                                                                "Yes",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              color:
                                                                  Colors.green,
                                                              onPressed:
                                                                  () async {
                                                                if (await galleriesModel.removeImages(
                                                                    galleriesModel
                                                                        .getGallery(
                                                                            widget.title),
                                                                    this.selectedImages)) {
                                                                  imageDisplayModel.removeImages(
                                                                      galleriesModel
                                                                          .getGallery(
                                                                              widget.title),
                                                                      this.selectedImages);
                                                                  setState(() {
                                                                    this.editing =
                                                                        false;
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                  ));
                                        }
                                        break;
                                      }
                                    case "Move":
                                      {
                                        if (this.selectedImages.length > 0) {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      title: Center(
                                                        child:
                                                            Text("Move Images"),
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        0),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[100],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              hint: Text(
                                                                galleriesModel
                                                                            .getGalleries()
                                                                            .length >
                                                                        1
                                                                    ? "Select a gallery"
                                                                    : "No other galleries found",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17),
                                                              ),
                                                              isExpanded: true,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 20),
                                                              iconSize: 25.0,
                                                              value: galleriesModel
                                                                          .getGalleries()
                                                                          .length >
                                                                      1
                                                                  ? this
                                                                      .selectedGallery
                                                                  : "No other galleries found",
                                                              onChanged: (String
                                                                  value) {
                                                                setState(() {
                                                                  selectedGallery =
                                                                      value;
                                                                });
                                                              },
                                                              underline:
                                                                  SizedBox(),
                                                              items: galleriesModel
                                                                  .getGalleries()
                                                                  .where(
                                                                      (item) {
                                                                return item
                                                                        .name !=
                                                                    widget
                                                                        .title;
                                                              }).map((gallery) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: gallery
                                                                      .name,
                                                                  child: Text(
                                                                    gallery
                                                                        .name,
                                                                    style: TextStyle(
                                                                        color: Colors.grey[
                                                                            600],
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  child:
                                                                      RaisedButton(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            new BorderRadius.circular(5.0)),
                                                                    child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    color: Colors
                                                                        .grey,
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ),
                                                                ),
                                                                Container(
                                                                  child: RaisedButton(
                                                                      disabledColor: Colors.grey[300],
                                                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                      child: Text(
                                                                        "Move",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                      color: Colors.green,
                                                                      onPressed: () async {
                                                                        if (galleriesModel.getGalleries().length -
                                                                                1 >
                                                                            0) {
                                                                          await galleriesModel.moveImages(
                                                                              widget.title,
                                                                              this.selectedGallery,
                                                                              List.from(this.selectedImages));
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      }),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              });
                                        }
                                        break;
                                      }
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return choices.map((Choice choice) {
                                    return PopupMenuItem<Choice>(
                                      value: choice,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(choice.title),
                                          Icon(choice.icon, color: Colors.grey),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                },
                              )
                            : SizedBox(),
                        this.editing
                            ? IconButton(
                                color: this.selectedImages.length ==
                                            galleriesModel
                                                .getGallery(widget.title)
                                                .getImages()
                                                .length &&
                                        this.selectedImages.length > 0
                                    ? Colors.blue[800]
                                    : Colors.black,
                                onPressed: () {
                                  if (this.selectedImages.length <
                                      galleriesModel
                                          .getGallery(widget.title)
                                          .getImages()
                                          .length) {
                                    setState(() {
                                      selectedImages = galleriesModel
                                          .getGallery(widget.title)
                                          .getImages();
                                    });
                                  } else {
                                    setState(() {
                                      selectedImages = List<String>();
                                    });
                                  }
                                },
                                iconSize: 25,
                                icon: Icon(Icons.select_all),
                              )
                            : SizedBox(),
                        !this.editing
                            ? IconButton(
                                color: Colors.black,
                                onPressed: () {
                                  galleriesModel
                                      .setSelectedGallery(widget.title);
                                  cameraModel.goToCamera(widget.title);
                                  Navigator.pop(context);
                                },
                                iconSize: 30,
                                icon: Icon(
                                  Icons.add,
                                ))
                            : SizedBox(),
                        IconButton(
                          color: this.editing ? Colors.blue[800] : Colors.black,
                          onPressed: () {
                            this.toogleEditing();
                          },
                          iconSize: 25,
                          icon: Icon(Icons.edit),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class Header extends StatelessWidget {
  final String title;
  const Header({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleriesModel>(builder:
        (BuildContext context, GalleriesModel galleriesModel, Widget child) {
      return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 70),
        child: Stack(
          //SvgPicture.asset('assets/wave.svg')
          children: <Widget>[
            Center(
                child: Column(
              children: <Widget>[
                Text(
                  this.title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30.0),
                ),
                Padding(
                  padding: EdgeInsets.all(2),
                ),
                Text(
                  galleriesModel
                          .getGallery(this.title)
                          .getImages()
                          .length
                          .toString() +
                      " images",
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15.0),
                )
              ],
            )),
          ],
        ),
      );
    });
  }
}
