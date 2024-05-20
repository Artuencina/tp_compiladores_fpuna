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

class CardTexto extends StatefulWidget {
  final String titulo;
  final Function(File) onFileSelected;

  const CardTexto(
      {super.key, required this.titulo, required this.onFileSelected});

  @override
  State<CardTexto> createState() => _CardTextoState();
}

class _CardTextoState extends State<CardTexto> {
  File? file;
  String? text;

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

      widget.onFileSelected(file!);
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
              child: TextField(
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
