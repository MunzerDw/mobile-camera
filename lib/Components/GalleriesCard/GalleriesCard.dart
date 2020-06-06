import 'dart:async';
import 'dart:io';
import 'package:App/Models/GalleriesModel.dart';
import 'package:App/Pages/GalleryDisplay/GalleryDisplay.dart';
import 'package:App/Storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class GalleriesCard extends StatefulWidget {
  final String title;
  final Function goToCamera;
  const GalleriesCard(
      {@required this.title, @required this.goToCamera, Key key})
      : super(key: key);

  @override
  GalleriesCardState createState() => GalleriesCardState();
}

class GalleriesCardState extends State<GalleriesCard> {
  TextEditingController textFieldController = TextEditingController();
  bool editing = false;

  @override
  void initState() {
    this.textFieldController.text = widget.title;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var galleriesModel = Provider.of<GalleriesModel>(context);
    var galleryModel = galleriesModel.getGallery(widget.title);

    return Card(
      elevation: 3,
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(2, 0, 2, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: GestureDetector(
        // borderRadius: BorderRadius.only(
        //   bottomLeft: const Radius.circular(20.0),
        //   bottomRight: const Radius.circular(20.0),
        //   topLeft: const Radius.circular(20.0),
        //   topRight: const Radius.circular(20.0),
        // ),
        onTap: () async {
          Navigator.push(
            context,
            // PageRouteBuilder(
            //   pageBuilder: (c, a1, a2) => GalleryDisplay(
            //     title: widget.title,
            //     goToCamera: widget.goToCamera,
            //     galleries: List.of(widget.galleries),
            //   ),
            //   transitionsBuilder: (BuildContext context,
            //       Animation<double> animation,
            //       Animation<double> secondaryAnimation,
            //       Widget child) {
            //     return new SlideTransition(
            //       position: new Tween<Offset>(
            //         begin: const Offset(1.0, 0.0),
            //         end: Offset.zero,
            //       ).animate(animation),
            //       child: child,
            //     );
            //   },
            //   transitionDuration: Duration(milliseconds: 150),
            // ),
            MaterialPageRoute(
              builder: (context) => GalleryDisplay(
                title: widget.title,
                goToCamera: widget.goToCamera,
              ),
            ),
          ).then((onValue) {
            // widget.updateNumbers();
          });
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
                        border: Border(
                            bottom: BorderSide(
                      color:
                          this.editing ? Colors.blueAccent : Colors.transparent,
                      width: 1.0,
                    ))),
                    child: TextField(
                      autofocus: true,
                      controller: this.textFieldController,
                      enabled: this.editing,
                      style: TextStyle(color: Colors.black, fontSize: 25),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            bottom: -15,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none),
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
                    galleryModel.getImages().length.toString() + " images",
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
                      color: this.editing ? Colors.blue[300] : Colors.blue[800],
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        if (editing) {
                          if (await galleryModel
                              .editGalleryName(this.textFieldController.text)) {
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
                        galleriesModel.remove(widget.title);
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
