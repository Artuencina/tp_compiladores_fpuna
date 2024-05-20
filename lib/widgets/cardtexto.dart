//Card stateful widget
//Tiene un titulo arriba (parametro)
//Abajo tiene un icono de archivo y un boton que dice "Seleccionar archivo"
//En la card tambien se puede hacer drop directamente del archivo
//Al seleccionar un archivo, se muestra el texto del archivo en la card
//Y un boton para quitar el archivo

// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

import 'package:speech_analytics/analizador.dart';

class CardTexto extends StatefulWidget {
  final String titulo;

  const CardTexto({super.key, required this.titulo});

  @override
  State<CardTexto> createState() => CardTextoState();
}

class CardTextoState extends State<CardTexto> {
  File? file;
  String? text;
  bool procesado = false;

  void _openFileExplorer() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null) return;

      //Verificar si es web
      if (kIsWeb) {
        file = File(result.files.single.name);
        //Convertir bytes a string
        text = String.fromCharCodes(result.files.single.bytes!);
      } else {
        file = File(result.files.single.path!);
        text = await file!.readAsString();
      }

      setState(() {});
    } on PlatformException catch (e) {
      print('Error: $e');
      //Otro catch
    } catch (e) {
      print('Error general: $e');
      //Otro catch
    }
  }

  void _removeFile() {
    setState(() {
      file = null;
      text = null;
      procesado = false;
    });
  }

  //Funcion que procesa la entrada
  void procesarEntrada() {
    //Si no hay archivo, no hacer nada
    if (file == null) return;

    //Procesar el texto
    //final analizador = Analizador();

    //Como todavia no funciona mostramos una imagen de un gatito
    //que dice "no hace nada"
    setState(() {
      procesado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[100],
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  widget.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (file != null) ...[
                //Mostrar icono para quitar archivo
                IconButton(
                  onPressed: _removeFile,
                  icon: const Icon(Icons.close),
                ),
              ]
            ],
          ),
          if (file != null) ...[
            //Mostrar nombre del archivo
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(file!.path.split('/').last),
            ),
            //Mostrar texto del archivo
            Flexible(
              child: procesado
                  ? Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: NetworkImage(
                            "https://pbs.twimg.com/media/GBkYdHibwAA2eIm?format=jpg&name=900x900"),
                        fit: BoxFit.scaleDown,
                      )),
                    )
                  : TextField(
                      controller: TextEditingController(text: text),
                      maxLines: null,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
            ),
          ] else ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.file_copy, size: 50),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _openFileExplorer,
                    child: const Text('Seleccionar archivo'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
