import 'dart:async';
import 'dart:math';
import 'package:App/Pages/Galleries/Galleries.dart';
import 'package:App/Pages/ImageDisplay/ImageDisplay.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class Settings extends StatefulWidget {
  final List<String> galleries;
  final int defaultGalleryIndex;
  final Function setDefaultGalleryIndex;
  Settings(
      {@required this.galleries,
      @required this.defaultGalleryIndex,
      @required this.setDefaultGalleryIndex});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String selectedGallery;

  @override
  void initState() {
    selectedGallery = widget.defaultGalleryIndex >= widget.galleries.length
        ? "Empty"
        : widget.galleries[widget.defaultGalleryIndex];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Center(
                child: Container(
              padding: EdgeInsets.fromLTRB(20, 100, 20, 100),
              child: Text(
                "Settings",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 40.0,
                    color: Colors.black),
              ),
            )),
            Card(
              elevation: 3,
              margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding:
                    EdgeInsets.only(left: 20, top: 40, bottom: 40, right: 30),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Default Gallery",
                      style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            selectedGallery = value;
                            widget.setDefaultGalleryIndex(
                                widget.galleries.indexOf(value));
                          });
                        },
                        underline: SizedBox(),
                        value: selectedGallery,
                        elevation: 2,
                        style: TextStyle(color: Colors.grey[600], fontSize: 17),
                        iconSize: 40.0,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
