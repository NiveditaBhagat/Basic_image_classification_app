import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool ?_isLoading;
 File ?_image;
  List ?outputs;
  final _imagePicker= ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading=true;
     
     loadModel().then((value){
      setState(() {
        _isLoading=false;
      });
     });
  }

  loadModel() async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
       );
  }

  pickImage()async {
    // ignore: deprecated_member_use
    var image= await _imagePicker.getImage(source: ImageSource.gallery);
    if(image==null)return null;
    setState(() {
      _isLoading=true;
      _image=File(image.path);

    });
   classifyImage(_image!);
  }

   classifyImage(File image)async {
      var output =await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        _isLoading=false;
        outputs=output;
      });
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog breed Classification'),
      ),
      body: _isLoading! ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ): Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image==null? Container():
            Container(
              child: Image.file(_image!),
              height: 500,
              width: MediaQuery.of(context).size.width-200,
            ),
            SizedBox(
              height: 20,
            ),
            outputs!=null?
            Text(
              '${outputs![0]["label"]}'.replaceAll(RegExp(r'[0-9]'), ''),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
            ): Text()
          ],
        ),
      )
    );
  }
}