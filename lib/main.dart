import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  //para pedir permiso
  WidgetsFlutterBinding.ensureInitialized();

  //obtiene lista de la camara disponible sjsjsjs equis de
  final cameras = await availableCameras();

  //usa una caamra
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        //pasa la camara al widget
        camera: firstCamera,
      ),
    ),
  );
}

//la pantalla de la camara
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    //para mostrar la imagen tomada
    _controller = CameraController(
        // usa la camara principal
      widget.camera,
      //resolucion de la camara

      ResolutionPreset.medium,
    );

    //este controlador devuelve un fuuture (fiutchur en ingles :v)
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sacar fotito')),
      //espera hasta que la camara cargue para iniciar el controlador
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //si el future se compeltó, devuelve el preview
            return CameraPreview(_controller);
          } else {
            //sino, muestra cargando
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        
        onPressed: () async {
        
          try {
        
            await _initializeControllerFuture;
          // para guardar la foto en una memoria temporal
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            
            await _controller.takePicture(path);

            //muestra en otra pantalla la foto sacada
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path),
              ),
            );
          } catch (e) {
            
            print(e);
          }
        },
      ),
    );
  }
}

//widget que muestra la foto recien tomada
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('muestra la fotito')),
    
      body: Image.file(File(imagePath)),
    );
  }
}
