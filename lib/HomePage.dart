import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  GlobalKey globalKey = new GlobalKey();

  String headerText="";
  String footerText="";

  File _image;
  File _imageFile;

  Random rng =new Random();

  bool imageSelected=false;

  Future getImage() async{
    var image;
    try{
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    catch(platformException){
      print("not allowing" + platformException);
    }
    setState(() {
      if(image!=null){
        imageSelected=true;
      }
      else{

      }
      _image=image;
    });
    new Directory('storage/emulated/0/' + 'MemeGenerator')
        .create(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 50,),
              Image.asset("assets/images/smile.png",height: 80,),
              SizedBox(height: 12.0,),
              Image.asset("assets/images/memegenrator.png",height: 70,),
              SizedBox(
                height: 14,
              ),
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    _image!=null ? Image.file(_image, height: 300,fit: BoxFit.fitHeight,) : Container(),
                    Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                           child:Text(headerText.toUpperCase(),
                             textAlign: TextAlign.center,
                             style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 26.0,
                            color: Colors.black,
                               shadows: <Shadow>[
                                 Shadow(
                                   offset: Offset(2.0, 2.0),
                                   blurRadius: 3.0,
                                   color: Colors.black87,
                                 ),
                                 Shadow(
                                   offset: Offset(2.0, 2.0),
                                   blurRadius: 8.0,
                                   color: Colors.black87,
                                 ),
                               ],
                          ),),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                           child : Text(
                             footerText.toUpperCase(),
                             textAlign: TextAlign.center,
                             style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 26.0,
                            color: Colors.black,
                               shadows: <Shadow>[
                                 Shadow(
                                   offset: Offset(2.0, 2.0),
                                   blurRadius: 3.0,
                                   color: Colors.black87,
                                 ),
                                 Shadow(
                                   offset: Offset(2.0, 2.0),
                                   blurRadius: 8.0,
                                   color: Colors.black87,
                                 ),
                               ],
                          ),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              imageSelected ? Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  TextField(
                    onChanged: (val){
                      setState(() {
                        headerText=val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Header Text",
                    ),
                  ),
                  SizedBox(height: 12,),
                  TextField(
                    onChanged: (val){
                      setState(() {
                        footerText=val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Footer Text",
                    ),
                  ),
                  RaisedButton(
                    onPressed: (){
                      takeScreenshot();
                    },
                    child: Text("Save"),
                  ),
                ],
              ),
              ) : Container(
                child: Text("Select image to get started"),
              ),
              _imageFile!=null ? Image.file(_imageFile) : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_a_photo),
        onPressed: (){
          getImage();
        },
      ),
    );
  }

  takeScreenshot() async{
    RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    final imgFile = new File('$directory/screenshot${rng.nextInt(200)}.png');
    setState(() {
      _imageFile=imgFile;
    });
    _saveFile(file: _imageFile);
    imgFile.writeAsBytes(pngBytes);
  }

  _saveFile({File file}) async{
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }
}

_askPermission() async{
  Map<PermissionGroup, PermissionStatus> Permissions = await PermissionHandler().requestPermissions([PermissionGroup.photos]);
}
