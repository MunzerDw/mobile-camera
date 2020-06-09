import 'dart:async';
import 'dart:math';
import 'package:App/Components/AddGallery/AddGallery.dart';
import 'package:App/Components/GalleriesCard/GalleriesCard.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../Models/GalleriesModel.dart';
import '../../Storage.dart';

class Galleries extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10, 5),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => AddGallery());
            },
            backgroundColor: Colors.green[300],
            child: Icon(Icons.add),
            elevation: 2,
          ),
        ),
        body: Container(
            color: Colors.grey[100],
            child: Column(
              children: <Widget>[
                Expanded(child: Consumer<GalleriesModel>(builder:
                    (BuildContext context, GalleriesModel galleriesModel,
                        Widget child) {
                  return AnimatedList(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 80),
                    shrinkWrap: true,
                    key: galleriesModel.listKey,
                    initialItemCount: galleriesModel.galleries.length + 1,
                    itemBuilder: (context, index, animation) =>
                        galleriesModel.buildItem(
                            context,
                            index,
                            (index == 0 ? 0 : index - 1) >=
                                    galleriesModel.galleries.length
                                ? ""
                                : galleriesModel
                                    .galleries[index == 0 ? 0 : index - 1]
                                    .getName(),
                            animation),
                  );
                })),
              ],
            )));
  }
}
