import 'dart:async';
import 'dart:io';
import 'package:App/Pages/GalleryDisplay/GalleryDisplay.dart';
import 'package:App/Storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GalleriesCard extends StatefulWidget {
  final String title;
  final Function deleteGallery;
  final Function editGallery;
  final TextEditingController textFieldController;

  const GalleriesCard(
      {@required this.title,
      @required this.deleteGallery,
      @required this.editGallery,
      @required this.textFieldController});

  @override
  GalleriesCardState createState() => GalleriesCardState();
}

class GalleriesCardState extends State<GalleriesCard> {
  bool editing = false;
  int totalImages = 0;

  void getTotalImages() {
    Storage.getImages(widget.title).then((onValue) {
      setState(() {
        totalImages = onValue.length;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this.getTotalImages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(2, 0, 2, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.only(
          bottomLeft: const Radius.circular(20.0),
          bottomRight: const Radius.circular(20.0),
          topLeft: const Radius.circular(20.0),
          topRight: const Radius.circular(20.0),
        ),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GalleryDisplay(
                title: widget.title,
                updateTotolImagesNumber: this.getTotalImages,
              ),
            ),
          );
        },
        child: Container(
          padding: new EdgeInsets.fromLTRB(20, 40, 20, 50),
          alignment: Alignment.centerLeft,
          decoration: new BoxDecoration(
            boxShadow: [
              // new BoxShadow(
              //   color: Colors.grey[300],
              //   blurRadius: 20.0,
              //   spreadRadius: 5.0,
              //   offset: Offset(0, 0)
              // ),
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(20.0),
              bottomRight: const Radius.circular(20.0),
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                        border: this.editing
                            ? Border(
                                bottom: BorderSide(
                                color: Colors.blueAccent,
                                width: 1.0,
                              ))
                            : null),
                    child: TextField(
                      autofocus: true,
                      controller: widget.textFieldController,
                      enabled: this.editing,
                      style: TextStyle(color: Colors.black, fontSize: 25),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            bottom: -15,
                          ),
                          border: InputBorder.none),
                    ),
                  ),
                  // Text(
                  //   widget.title,
                  //   textAlign: TextAlign.left,
                  //   style: new TextStyle(
                  //       color: Colors.grey[800],
                  //       fontWeight: FontWeight.w400,
                  //       fontSize: 20.0),
                  // ),
                  SizedBox(height: 3),
                  Text(
                    this.totalImages.toString() + " images",
                    textAlign: TextAlign.left,
                    style: new TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  MaterialButton(
                    padding: EdgeInsets.all(1),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    color: Colors.white,
                    clipBehavior: Clip.hardEdge,
                    elevation: this.editing ? 3 : 0,
                    height: 10,
                    minWidth: 10,
                    shape: new CircleBorder(),
                    child: IconButton(
                      color: this.editing ? Colors.blue[800] : Colors.blue[300],
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        if (editing) {
                          if (await widget.editGallery(
                              widget.title, widget.textFieldController.text)) {
                            setState(() {
                              editing = !editing;
                            });
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
                                          "Gallery name is empty or already exists",
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
                                                "Ok",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              color: Colors.grey,
                                              onPressed: () {
                                                Navigator.pop(context);
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
                        } else {
                          setState(() {
                            editing = !editing;
                          });
                        }
                      },
                    ),
                    onPressed: () {},
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(1),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    color: Colors.transparent,
                    clipBehavior: Clip.hardEdge,
                    elevation: 0.0,
                    height: 10,
                    minWidth: 10,
                    shape: new CircleBorder(),
                    child: IconButton(
                      color: Colors.orange[300],
                      icon: Icon(Icons.delete),
                      onPressed: () async {
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
                                        "Deleting " + widget.title,
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "Are you sure you want to delete?",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      )
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
                                              "No",
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
                                              "Yes",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            color: Colors.green,
                                            onPressed: () async {
                                              if (await widget.deleteGallery(
                                                  widget.textFieldController
                                                      .text)) {
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                ));
                      },
                    ),
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
