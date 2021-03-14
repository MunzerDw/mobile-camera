import 'dart:async';
import 'dart:io';
import 'package:App/Components/AddGallery/AddGallery.dart';
import 'package:App/Models/CameraModel.dart';
import 'package:App/Models/GalleriesModel.dart';
import 'package:App/Models/GalleryModel.dart';
import 'package:App/Models/ImageDisplayModel.dart';
import 'package:App/Pages/Blink/Blink.dart';
import 'package:App/Pages/ImageDisplay/ImageDisplay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

class Camera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black87,
      ),
    );
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TopRow(),
          Expanded(child: CameraSection()),
          BottomRow(),
        ],
      ),
    );
  }
}

class TopRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2(builder: (BuildContext context,
        GalleriesModel galleriesModel,
        ImageDisplayModel imageDisplayModel,
        Widget child) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
        color: Colors.black,
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              galleriesModel.getGalleries().length != 0
                  ? GalleriesList()
                  : AddGalleryButton(),
              NewImages()
            ],
          ),
        ),
      );
    });
  }
}

class CameraSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<CameraModel>(
        builder: (BuildContext context, CameraModel cameraModel, Widget child) {
      return FutureBuilder<void>(
        future: cameraModel.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(cameraModel.cameraController); // this is my CameraPreview
          } else {
            // Otherwise, display a loading indicator
            return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
                color: Colors.black,
            );
          }
        },
      );
    });
  }
}

class BottomRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraModel>(
        builder: (BuildContext context, CameraModel cameraModel, Widget child) {
      return Container(
          padding: EdgeInsets.only(top: 25, bottom: 25, left: 35, right: 35),
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
                  cameraModel.pageViewController.animateToPage(0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
              ),
              TakePictureButton(),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  size: 35,
                ),
                color: Colors.white,
                onPressed: () {
                  cameraModel.pageViewController.animateToPage(2,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
              ),
            ],
          ));
    });
  }
}

class TakePictureButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3(builder: (BuildContext context,
        GalleriesModel galleriesModel,
        CameraModel cameraModel,
        ImageDisplayModel imageDisplayModel,
        Widget child) {
      return Container(
          width: 86,
          height: 86,
          decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[400], width: 5.0)),
          child: RaisedButton(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(86),
            ),
            color: Colors.white,
            onPressed: () async {
              if (galleriesModel.getGalleries().length > 0) {
                final Directory _appDocDir =
                    await getApplicationDocumentsDirectory();
                String path = _appDocDir.path +
                    '/galleries/' +
                    galleriesModel.selectedGallery.name +
                    '/${DateTime.now()}.png';
                try {
                  await cameraModel.initializeControllerFuture;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Blink(),
                    ),
                  );
                  Future.delayed(Duration(milliseconds: 150), () {
                    Navigator.pop(context);
                  });
                  await cameraModel.cameraController.takePicture(path);
                  imageDisplayModel.addImage(
                      galleriesModel.selectedGallery, path);
                  galleriesModel.selectedGallery.addImage(path);
                } catch (e) {
                  print(e);
                }
              } else {
                showDialog(
                    context: context, builder: (_) => AddGalleryDialog());
              }
            },
          ));
    });
  }
}

class AddGalleryDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
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
                "Please add a gallery first",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orangeAccent),
              ),
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
                      "cancel",
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
                      "add",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.green,
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context, builder: (_) => AddGallery());
                    },
                  ),
                )
              ],
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
    );
  }
}

class GalleriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GalleriesModel>(
      builder:
          (BuildContext context, GalleriesModel galleriesModel, Widget child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: DropdownButton<String>(
            items: galleriesModel.getGalleries().map((GalleryModel gallery) {
              return DropdownMenuItem<String>(
                value: gallery.name,
                child: Text(gallery.name),
              );
            }).toList(),
            onChanged: (value) {
              galleriesModel.setSelectedGallery(value);
            },
            underline: SizedBox(),
            value: galleriesModel.selectedGallery.name,
            elevation: 2,
            style: TextStyle(color: Colors.grey[600], fontSize: 20),
            iconSize: 40.0,
          ),
        );
      },
    );
  }
}

class AddGalleryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: RaisedButton(
          color: Colors.white,
          clipBehavior: Clip.hardEdge,
          elevation: 3,
          shape: CircleBorder(),
          child: IconButton(
              color: Colors.blue[800],
              icon: Icon(Icons.add),
              onPressed: () {
                showDialog(context: context, builder: (_) => AddGallery());
              }),
          onPressed: () {},
        ),
      ),
    );
  }
}

class NewImages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<ImageDisplayModel>(builder: (BuildContext context,
          ImageDisplayModel imageDisplayModel, Widget child) {
        return FittedBox(
            child: imageDisplayModel.isEmpty()
                ? Container(width: 60, height: 60)
                : MaterialButton(
                    onPressed: () {
                      imageDisplayModel.setCurrentImageIndex(
                          imageDisplayModel.getLastIndex());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDisplay(),
                        ),
                      ).then((onValue) {
                        imageDisplayModel.showTopBar();
                      });
                    },
                    child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            image: DecorationImage(
                                image: FileImage(
                                    File(imageDisplayModel.getLastImage())),
                                fit: BoxFit.cover))),
                  ));
      }),
    );
  }
}
