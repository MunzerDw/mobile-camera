import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:App/Components/AddGallery/AddGallery.dart';
import 'package:App/Components/GalleriesCard/GalleriesCard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class ImageDisplay extends StatefulWidget {
  final int index;
  final String gallery;
  final Function deleteImageFromGallery;
  final List<String> imagesFromParent;
  ImageDisplay(
      {@required this.index,
      this.gallery,
      this.deleteImageFromGallery,
      this.imagesFromParent});

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  PageController pageViewController;
  PhotoViewControllerBase photoViewController;
  PhotoViewScaleStateController scaleStateController;
  bool zoomedOut = true;
  int currentImageIndex;
  bool topBarVisible = true;

  void toogleTopBar() {
    setState(() {
      topBarVisible = !this.topBarVisible;
    });
    if (this.topBarVisible) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(
          List.from([SystemUiOverlay.bottom]));
    }
  }

  @override
  void initState() {
    currentImageIndex = widget.index;
    photoViewController = PhotoViewController();
    scaleStateController = PhotoViewScaleStateController();
    pageViewController = PageController(initialPage: currentImageIndex);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black87,
      ),
    );
    super.initState();
    Future.delayed(Duration(milliseconds: 400), this.toogleTopBar);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PhotoViewScaleState initialState = PhotoViewScaleState.initial;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image
        backgroundColor: Colors.black,
        body: GestureDetector(
            onTap: () {
              this.toogleTopBar();
            },
            onVerticalDragEnd: this.zoomedOut
                ? (DragEndDetails dragEndDetails) {
                    if (dragEndDetails.velocity.pixelsPerSecond.dy > 0) {
                      Navigator.pop(context);
                    }
                  }
                : null,
            child: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    child: PageView(
                        physics: !this.zoomedOut
                            ? NeverScrollableScrollPhysics()
                            : null,
                        controller: pageViewController,
                        onPageChanged: (newIndex) {
                          setState(() {
                            currentImageIndex = newIndex;
                          });
                        },
                        children: widget.imagesFromParent
                            .toList()
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
                                                if (scaleStateController
                                                        .scaleState ==
                                                    initialState) {
                                                  setState(() {
                                                    zoomedOut = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    zoomedOut = false;
                                                  });
                                                }
                                              },
                                              scaleStateController:
                                                  scaleStateController,
                                              controller: photoViewController,
                                              onTapUp: (BuildContext,
                                                  TapUpDetails,
                                                  PhotoViewControllerValue) {
                                                this.toogleTopBar();
                                                if (scaleStateController
                                                        .scaleState ==
                                                    PhotoViewScaleState
                                                        .originalSize) {
                                                  setState(() {
                                                    zoomedOut = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    zoomedOut = false;
                                                  });
                                                }
                                              },
                                              gaplessPlayback: true,
                                              minScale: PhotoViewComputedScale
                                                  .contained,
                                              maxScale: PhotoViewComputedScale
                                                      .covered *
                                                  2.0,
                                              customSize:
                                                  MediaQuery.of(context).size,
                                              imageProvider:
                                                  FileImage(File(item)),
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
                  ),
                  AnimatedOpacity(
                    opacity: this.topBarVisible ? 1.0 : 0.0,
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
                                onPressed: !this.topBarVisible
                                    ? null
                                    : () {
                                        Navigator.of(context).pop();
                                      },
                                iconSize: 25,
                                color: Colors.white,
                                icon: Icon(Icons.arrow_back_ios),
                              ),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    onPressed: !this.topBarVisible
                                        ? null
                                        : () async {
                                            if (widget
                                                    .imagesFromParent.length !=
                                                0) {
                                              if (widget.imagesFromParent !=
                                                  null) {
                                                if (!(await widget
                                                    .deleteImageFromGallery(this
                                                        .currentImageIndex))) {
                                                  Navigator.pop(context);
                                                  return;
                                                }
                                              }
                                            } else {
                                              Navigator.pop(context);
                                            }
                                            if (widget
                                                    .imagesFromParent.length !=
                                                0) {
                                              if (this.currentImageIndex !=
                                                  widget.imagesFromParent
                                                      .length) {
                                                setState(() {
                                                  currentImageIndex =
                                                      (this.currentImageIndex -
                                                              1) %
                                                          widget
                                                              .imagesFromParent
                                                              .length;
                                                });
                                                if (this.currentImageIndex ==
                                                    widget.imagesFromParent
                                                            .length -
                                                        1) {
                                                  setState(() {
                                                    currentImageIndex = 0;
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  currentImageIndex =
                                                      (this.currentImageIndex -
                                                              1) %
                                                          widget
                                                              .imagesFromParent
                                                              .length;
                                                });
                                              }
                                            } else {
                                              Navigator.pop(context);
                                            }
                                            if (this
                                                    .widget
                                                    .imagesFromParent
                                                    .length !=
                                                0) {
                                              pageViewController.animateToPage(
                                                this.currentImageIndex,
                                                duration:
                                                    Duration(milliseconds: 250),
                                                curve: Curves.ease,
                                              );
                                            }

                                            // print(this.currentImageIndex);
                                            // print("length 2: " +
                                            //     widget.imagesFromParent[
                                            //         this.currentImageIndex]);
                                            // print("length 2: " +
                                            //     widget.imagesFromParent.length
                                            //         .toString());
                                          },
                                    iconSize: 25,
                                    color: Colors.white,
                                    icon: Icon(Icons.delete),
                                  ),
                                  IconButton(
                                    onPressed: !this.topBarVisible
                                        ? null
                                        : () async {
                                            final Uint8List bytes =
                                                await new File(widget
                                                            .imagesFromParent[
                                                        this.currentImageIndex])
                                                    .readAsBytes();
                                            await Share.file(
                                                'Image',
                                                'image.jpg',
                                                bytes.buffer.asUint8List(),
                                                'image/jpg');
                                            // final Uint8List bytes = await new File(widget.imagePath).readAsBytes();
                                            // await Share.file('esys image', 'esys.png', bytes.buffer.asUint8List(), 'image/png');
                                            // var request = await HttpClient().getUrl(
                                            //     Uri.parse(widget.imagesFromParent[
                                            //         currentImageIndex]));
                                            // var response = await request.close();
                                            // Uint8List bytes =
                                            //     await consolidateHttpClientResponseBytes(
                                            //         response);
                                          },
                                    iconSize: 25,
                                    color: Colors.white,
                                    icon: Icon(Icons.share),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
