import 'dart:io';
import 'package:App/Models/CameraModel.dart';
import 'package:App/Models/GalleriesModel.dart';
import 'package:App/Models/GalleryDisplayModel.dart';
import 'package:App/Models/ImageDisplayModel.dart';
import 'package:App/Pages/ImageDisplay/ImageDisplay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class GalleryDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                children: <Widget>[Header(), Images()],
              ),
              Container(
                padding: EdgeInsets.only(top: 60, left: 15, right: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Consumer<GalleryDisplayModel>(builder:
                              (BuildContext context,
                                  GalleryDisplayModel galleryDisplayModel,
                                  Widget child) {
                            return !galleryDisplayModel.editing
                                ? Container()
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ActionMenu(),
                                          SelectAllButton()
                                        ],
                                      )
                                    ],
                                  );
                          }),
                          GoToCameraButton(),
                          EditButton()
                        ])
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
  @override
  Widget build(BuildContext context) {
    return Consumer2(builder: (BuildContext context,
        GalleryDisplayModel galleryDisplayModel,
        GalleriesModel galleriesModel,
        Widget child) {
      return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 70),
        child: Stack(
          //SvgPicture.asset('assets/wave.svg')
          children: <Widget>[
            Center(
                child: Column(
              children: <Widget>[
                Text(
                  galleryDisplayModel.currentGallery.name,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30.0),
                ),
                Padding(
                  padding: EdgeInsets.all(2),
                ),
                Text(
                  galleryDisplayModel.currentGallery.images.length.toString() +
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

class Images extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2(builder: (BuildContext context,
        GalleryDisplayModel galleryDisplayModel,
        ImageDisplayModel imageDisplayModel,
        Widget child) {
      return galleryDisplayModel.currentGallery.images.isEmpty
          ? Center()
          : GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
              crossAxisCount: 4,
              children: List.generate(
                  galleryDisplayModel.currentGallery.images.length, (index) {
                return GestureDetector(
                  onLongPress: () {
                    if (!galleryDisplayModel.editing) {
                      galleryDisplayModel.toogleEditing();
                      galleryDisplayModel.selectImage(galleryDisplayModel
                          .currentGallery.images
                          .elementAt(index));
                    }
                  },
                  onTap: () {
                    if (!galleryDisplayModel.editing) {
                      imageDisplayModel.setCurrentImageIndex(index);
                      imageDisplayModel.addImages(
                          galleryDisplayModel.currentGallery,
                          galleryDisplayModel.currentGallery.getImages());
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
                      if (galleryDisplayModel.selectedImages.contains(
                          galleryDisplayModel.currentGallery.images
                              .elementAt(index))) {
                        galleryDisplayModel.deselectImage(galleryDisplayModel
                            .currentGallery.images
                            .elementAt(index));
                      } else {
                        galleryDisplayModel.selectImage(galleryDisplayModel
                            .currentGallery.images
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
                            image: FileImage(File(galleryDisplayModel
                                .currentGallery.images[index])),
                            fit: BoxFit.cover)),
                    child: galleryDisplayModel.editing
                        ? Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: galleryDisplayModel.selectedImages
                                        .contains(galleryDisplayModel
                                            .currentGallery.images
                                            .elementAt(index))
                                    ? Colors.white
                                    : Colors.white38,
                                border:
                                    Border.all(color: Colors.grey, width: 1)),
                            child: galleryDisplayModel.selectedImages.contains(
                                    galleryDisplayModel.currentGallery.images
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
            );
    });
  }
}

void deleteAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return Consumer3(builder: (BuildContext context,
            GalleryDisplayModel galleryDisplayModel,
            GalleriesModel galleriesModel,
            ImageDisplayModel imageDisplayModel,
            Widget child) {
          return AlertDialog(
            title: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 4.0, color: Colors.orangeAccent),
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
                  "Deleting " + galleryDisplayModel.currentGallery.name,
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600),
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                      child: Text(
                        "No",
                        style: TextStyle(color: Colors.white),
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
                          borderRadius: new BorderRadius.circular(5.0)),
                      child: Text(
                        "Yes",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green,
                      onPressed: () async {
                        if (await galleriesModel.removeImages(
                            galleryDisplayModel.currentGallery,
                            galleryDisplayModel.selectedImages)) {
                          imageDisplayModel.removeImages(
                              galleryDisplayModel.currentGallery,
                              galleryDisplayModel.selectedImages);
                          galleryDisplayModel.clearSelectedImages();
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
          );
        });
      });
}

void moveAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return Consumer3(builder: (BuildContext context,
            GalleryDisplayModel galleryDisplayModel,
            GalleriesModel galleriesModel,
            ImageDisplayModel imageDisplayModel,
            Widget child) {
          return AlertDialog(
            title: Center(
              child: Text("Move Images"),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: DropdownButton<String>(
                    hint: Text(
                      galleriesModel.getGalleries().length > 1
                          ? "Select a gallery"
                          : "No other galleries found",
                      style: TextStyle(fontSize: 17),
                    ),
                    isExpanded: true,
                    style: TextStyle(color: Colors.grey[600], fontSize: 20),
                    iconSize: 25.0,
                    value: galleriesModel.getGalleries().length > 1
                        ? galleryDisplayModel.selectedGallery.name
                        : "No other galleries found",
                    onChanged: (String value) {
                      galleryDisplayModel
                          .selectGallery(galleriesModel.getGallery(value));
                    },
                    underline: SizedBox(),
                    items: galleriesModel.getGalleries().where((item) {
                      return item.name !=
                          galleryDisplayModel.currentGallery.name;
                    }).map((gallery) {
                      return DropdownMenuItem<String>(
                        value: gallery.name,
                        child: Text(
                          gallery.name,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 20),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.grey,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        child: RaisedButton(
                            disabledColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0)),
                            child: Text(
                              "Move",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.green,
                            onPressed: () async {
                              if (galleriesModel.getGalleries().length - 1 >
                                  0) {
                                await galleriesModel.moveImages(
                                    galleryDisplayModel.currentGallery.name,
                                    galleryDisplayModel.selectedGallery.name,
                                    galleryDisplayModel.selectedImages);
                                imageDisplayModel.removeImages(
                                    galleryDisplayModel.currentGallery,
                                    galleryDisplayModel.selectedImages);
                                galleryDisplayModel.clearSelectedImages();
                                Navigator.pop(context);
                              }
                            }),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
      });
}

class ActionMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3(builder: (BuildContext context,
        GalleryDisplayModel galleryDisplayModel,
        GalleriesModel galleriesModel,
        ImageDisplayModel imageDisplayModel,
        Widget child) {
      return PopupMenuButton<Choice>(
        onSelected: (value) {
          switch (value.title) {
            case "Delete":
              {
                if (galleryDisplayModel.selectedImages.length > 0) {
                  deleteAlert(context);
                }
                break;
              }
            case "Move":
              {
                if (galleryDisplayModel.selectedImages.length > 0) {
                  try {
                    galleryDisplayModel.selectGallery(
                        galleriesModel.getGalleries().firstWhere((item) {
                      return item.name !=
                          galleryDisplayModel.currentGallery.name;
                    }));
                  } catch (e) {}
                  moveAlert(
                    context,
                  );
                }
                break;
              }
          }
        },
        itemBuilder: (BuildContext context) {
          const List<Choice> choices = const <Choice>[
            const Choice(title: 'Delete', icon: Icons.delete),
            const Choice(title: 'Move', icon: Icons.reply),
          ];
          return choices.map((Choice choice) {
            return PopupMenuItem<Choice>(
              value: choice,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(choice.title),
                  Icon(choice.icon, color: Colors.grey),
                ],
              ),
            );
          }).toList();
        },
      );
    });
  }
}

class SelectAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryDisplayModel>(builder: (BuildContext context,
        GalleryDisplayModel galleryDisplayModel, Widget child) {
      print(galleryDisplayModel.selectedImages.length);
      return IconButton(
        color: galleryDisplayModel.selectedImages.length ==
                    galleryDisplayModel.currentGallery.images.length &&
                galleryDisplayModel.selectedImages.length > 0
            ? Colors.blue[800]
            : Colors.black,
        onPressed: () {
          if (galleryDisplayModel.selectedImages.length <
              galleryDisplayModel.currentGallery.images.length) {
            galleryDisplayModel.selectAll();
          } else {
            galleryDisplayModel.clearSelectedImages();
          }
        },
        iconSize: 25,
        icon: Icon(Icons.select_all),
      );
    });
  }
}

class GoToCameraButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3(builder: (BuildContext context,
        GalleryDisplayModel galleryDisplayModel,
        GalleriesModel galleriesModel,
        CameraModel cameraModel,
        Widget child) {
      return IconButton(
          color: Colors.black,
          onPressed: () {
            galleriesModel
                .setSelectedGallery(galleryDisplayModel.currentGallery.name);
            cameraModel.goToCamera(galleryDisplayModel.currentGallery.name);
            Navigator.pop(context);
          },
          iconSize: 30,
          icon: Icon(
            Icons.add,
          ));
    });
  }
}

class EditButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryDisplayModel>(builder: (BuildContext context,
        GalleryDisplayModel galleryDisplayModel, Widget child) {
      return IconButton(
        color: galleryDisplayModel.editing ? Colors.blue[800] : Colors.black,
        onPressed: () {
          galleryDisplayModel.toogleEditing();
        },
        iconSize: 25,
        icon: Icon(Icons.edit),
      );
    });
  }
}
