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

class ImageDisplay extends StatefulWidget {
  ImageDisplay({Key key});

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> combineLists(List<List<String>> lists) {
    List<String> result = List<String>();
    for (var list in lists) {
      result.addAll(list);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var imageDisplayModel = Provider.of<ImageDisplayModel>(context);
    PhotoViewScaleState initialState = PhotoViewScaleState.initial;
    if (imageDisplayModel.topBarVisible) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(
          List.from([SystemUiOverlay.bottom]));
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image
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
                  Container(
                    child: PageView(
                        physics: !imageDisplayModel.zoomedOut
                            ? NeverScrollableScrollPhysics()
                            : null,
                        controller: imageDisplayModel.pageViewController,
                        onPageChanged: (newIndex) {
                          imageDisplayModel.setCurrentImageIndex(newIndex);
                        },
                        children: this
                            .combineLists(
                                imageDisplayModel.imagesMap.values.toList())
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
                                                        .scaleStateController
                                                        .scaleState ==
                                                    initialState) {
                                                  imageDisplayModel
                                                      .setZoomedOut(true);
                                                } else {
                                                  imageDisplayModel
                                                      .setZoomedOut(false);
                                                }
                                              },
                                              scaleStateController:
                                                  imageDisplayModel
                                                      .scaleStateController,
                                              controller: imageDisplayModel
                                                  .photoViewController,
                                              onTapUp: (BuildContext,
                                                  TapUpDetails,
                                                  PhotoViewControllerValue) {
                                                imageDisplayModel
                                                    .toogleTopBar();
                                                if (imageDisplayModel
                                                        .scaleStateController
                                                        .scaleState ==
                                                    PhotoViewScaleState
                                                        .originalSize) {
                                                  imageDisplayModel
                                                      .setZoomedOut(true);
                                                } else {
                                                  imageDisplayModel
                                                      .setZoomedOut(false);
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
                                  IconButton(
                                    onPressed: !imageDisplayModel.topBarVisible
                                        ? null
                                        : () async {
                                            if (imageDisplayModel
                                                    .imagesMap.values.length !=
                                                0) {
                                              if (imageDisplayModel
                                                      .imagesMap.values !=
                                                  null) {
                                                String path = this
                                                    .combineLists(
                                                        imageDisplayModel
                                                            .imagesMap.values
                                                            .toList())
                                                    .elementAt(imageDisplayModel
                                                        .currentImageIndex);
                                                GalleryModel gallery =
                                                    imageDisplayModel
                                                        .imagesMap.keys
                                                        .firstWhere((item) {
                                                  return item.images
                                                      .contains(path);
                                                });
                                                if (!await imageDisplayModel
                                                    .removeImage(
                                                        gallery, path)) {
                                                  Navigator.pop(context);
                                                  return;
                                                }
                                              }
                                            } else {
                                              Navigator.pop(context);
                                            }
                                            if (this
                                                    .combineLists(
                                                        imageDisplayModel
                                                            .imagesMap.values
                                                            .toList())
                                                    .length !=
                                                0) {
                                              if (imageDisplayModel
                                                      .currentImageIndex !=
                                                  this
                                                      .combineLists(
                                                          imageDisplayModel
                                                              .imagesMap.values
                                                              .toList())
                                                      .length) {
                                                imageDisplayModel.setCurrentImageIndex(
                                                    (imageDisplayModel
                                                                .currentImageIndex -
                                                            1) %
                                                        this
                                                            .combineLists(
                                                                imageDisplayModel
                                                                    .imagesMap
                                                                    .values
                                                                    .toList())
                                                            .length);
                                                if (imageDisplayModel
                                                        .currentImageIndex ==
                                                    this
                                                            .combineLists(
                                                                imageDisplayModel
                                                                    .imagesMap
                                                                    .values
                                                                    .toList())
                                                            .length -
                                                        1) {
                                                  imageDisplayModel
                                                      .setCurrentImageIndex(0);
                                                }
                                              } else {
                                                setState(() {
                                                  imageDisplayModel.setCurrentImageIndex(
                                                      (imageDisplayModel
                                                                  .currentImageIndex -
                                                              1) %
                                                          this
                                                              .combineLists(
                                                                  imageDisplayModel
                                                                      .imagesMap
                                                                      .values
                                                                      .toList())
                                                              .length);
                                                  ;
                                                });
                                              }
                                            } else {
                                              Navigator.pop(context);
                                            }

                                            // print(this.currentImageIndex);
                                            // print("length 2: " +
                                            //     galleryModel.getImages()[
                                            //         this.currentImageIndex]);
                                            // print("length 2: " +
                                            //     galleryModel.getImages().length
                                            //         .toString());
                                          },
                                    iconSize: 25,
                                    color: Colors.white,
                                    icon: Icon(Icons.delete),
                                  ),
                                  IconButton(
                                    onPressed: !imageDisplayModel.topBarVisible
                                        ? null
                                        : () async {
                                            final Uint8List bytes =
                                                await new File(this.combineLists(
                                                            imageDisplayModel
                                                                .imagesMap
                                                                .values)[
                                                        imageDisplayModel
                                                            .currentImageIndex])
                                                    .readAsBytes();
                                            await Share.file(
                                                'Image',
                                                'image.jpg',
                                                bytes.buffer.asUint8List(),
                                                'image/jpg');
                                            // final Uint8List bytes = await new File(widget.imagePath).readAsBytes();
                                            // await Share.file('esys image', 'esys.png', bytes.buffer.asUint8List(), 'image/png');
                                            // var request = await HttpClient().getUrl(
                                            //     Uri.parse(galleryModel.getImages()[
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
