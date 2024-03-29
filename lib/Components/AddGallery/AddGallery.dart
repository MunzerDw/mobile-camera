import 'package:App/Models/GalleriesModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddGallery extends StatefulWidget {
  @override
  _AddGalleryState createState() => _AddGalleryState();
}

class _AddGalleryState extends State<AddGallery> {
  final inputController = TextEditingController();
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 4.0, color: Colors.green),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(bottom: 20.0),
            child: Icon(
              Icons.add,
              color: Colors.green,
              size: 50,
            ),
          ),
          Text(
            "Add a new Gallery",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 35),
          AnimatedOpacity(
            opacity: this.error ? 1.0 : 0.0,
            duration: Duration(milliseconds: 100),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  margin: EdgeInsets.only(right: 5, top: 1),
                  child: Icon(
                    Icons.error,
                    color: Colors.redAccent,
                    size: 17,
                  ),
                ),
                Expanded(
                  child: Text(
                    "Gallery name is empty or already exists",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 17),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      content: Container(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: inputController,
                decoration: const InputDecoration(
                  hintText: 'Gallery name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      child: RaisedButton(
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
                    Consumer<GalleriesModel>(builder: (BuildContext context,
                        GalleriesModel galleriesModel, Widget child) {
                      return Container(
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          child: Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.green,
                          onPressed: () async {
                            await galleriesModel
                                .add(inputController.text)
                                .then((onValue) {
                              if (!onValue) {
                                setState(() {
                                  error = true;
                                });
                              } else {
                                Navigator.pop(context);
                              }
                            });
                          },
                        ),
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }
}
