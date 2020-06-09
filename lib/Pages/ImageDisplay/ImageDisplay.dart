import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:App/Models/GalleriesModel.dart';
import 'package:App/Models/GalleryModel.dart';
import 'package:App/Models/ImageDisplayModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:provider/provider.dart';

class ImageDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayModel>(builder: (BuildContext context,
        ImageDisplayModel imageDisplayModel, Widget child) {
      if (imageDisplayModel.topBarVisible) {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      } else {
        SystemChrome.setEnabledSystemUIOverlays(
            List.from([SystemUiOverlay.bottom]));
      }
      return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
              onTap: () {
                imageDisplayModel.toogleTopBar();
              },
              onVerticalDragEnd: imageDisplayModel.zoomedOut
                  ? (DragEndDetails dragEndDetails) {
                      if (dragEndDetails.velocity.pixelsPerSecond.dy > 0) {
                        Navigator.pop(context);
                      }
                    }
                  : null,
              child: Container(
                child: Stack(
                  children: <Widget>[
                    Images(),
                    TopBar(),
                  ],
                ),
              )));
    });
  }
}

class Images extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    PhotoViewScaleState initialState = PhotoViewScaleState.initial;
    return Consumer<ImageDisplayModel>(builder: (BuildContext context,
        ImageDisplayModel imageDisplayModel, Widget child) {
      return Container(
        child: PageView(
            physics: !imageDisplayModel.zoomedOut
                ? NeverScrollableScrollPhysics()
                : null,
            controller: imageDisplayModel.pageViewController,
            onPageChanged: (newIndex) {
              imageDisplayModel.setCurrentImageIndex(newIndex);
            },
            children: imageDisplayModel
                .getAllImages()
                .map(
                  (item) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: screenWidth,
                        height: screenHeight,
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Container(
                                width: screenWidth,
                                height: screenWidth * 1.5,
                                child: PhotoView(
                                  scaleStateChangedCallback:
                                      (PhotoViewScaleState) {
                                    if (imageDisplayModel
                                            .scaleStateController.scaleState ==
                                        initialState) {
                                      imageDisplayModel.setZoomedOut(true);
                                    } else {
                                      imageDisplayModel.setZoomedOut(false);
                                    }
                                  },
                                  scaleStateController:
                                      imageDisplayModel.scaleStateController,
                                  controller:
                                      imageDisplayModel.photoViewController,
                                  onTapUp: (BuildContext, TapUpDetails,
                                      PhotoViewControllerValue) {
                                    imageDisplayModel.toogleTopBar();
                                    if (imageDisplayModel
                                            .scaleStateController.scaleState ==
                                        PhotoViewScaleState.originalSize) {
                                      imageDisplayModel.setZoomedOut(true);
                                    } else {
                                      imageDisplayModel.setZoomedOut(false);
                                    }
                                  },
                                  gaplessPlayback: true,
                                  minScale: PhotoViewComputedScale.contained,
                                  maxScale:
                                      PhotoViewComputedScale.covered * 2.0,
                                  customSize: MediaQuery.of(context).size,
                                  imageProvider: FileImage(File(item)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
                .toList()),
      );
    });
  }
}

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayModel>(builder: (BuildContext context,
        ImageDisplayModel imageDisplayModel, Widget child) {
      return AnimatedOpacity(
        opacity: imageDisplayModel.topBarVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 250),
        child: Container(
          color: Colors.black54,
          padding: EdgeInsets.fromLTRB(15, 30, 15, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      SystemChrome.setEnabledSystemUIOverlays(
                          SystemUiOverlay.values);
                      Navigator.of(context).pop();
                    },
                    iconSize: 25,
                    color: Colors.white,
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  Row(
                    children: <Widget>[
                      DeleteIcon(),
                      ShareIcon(),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class DeleteIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayModel>(builder: (BuildContext context,
        ImageDisplayModel imageDisplayModel, Widget child) {
      return IconButton(
        onPressed: !imageDisplayModel.topBarVisible
            ? null
            : () async {
                if (await imageDisplayModel.removeCurrentImage()) {
                  if (imageDisplayModel.isEmpty()) {
                    Navigator.pop(context);
                  }
                }
              },
        iconSize: 25,
        color: Colors.white,
        icon: Icon(Icons.delete),
      );
    });
  }
}

class ShareIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayModel>(builder: (BuildContext context,
        ImageDisplayModel imageDisplayModel, Widget child) {
      return IconButton(
        onPressed: !imageDisplayModel.topBarVisible
            ? null
            : () async {
                final Uint8List bytes = await new File(imageDisplayModel
                        .getAllImages()[imageDisplayModel.currentImageIndex])
                    .readAsBytes();
                await Share.file('Image', 'image.jpg',
                    bytes.buffer.asUint8List(), 'image/jpg');
              },
        iconSize: 25,
        color: Colors.white,
        icon: Icon(Icons.share),
      );
    });
  }
}
