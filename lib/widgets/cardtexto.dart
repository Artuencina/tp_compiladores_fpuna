//Card stateful widget
//Tiene un titulo arriba (parametro)
//Abajo tiene un icono de archivo y un boton que dice "Seleccionar archivo"
//En la card tambien se puede hacer drop directamente del archivo
//Al seleccionar un archivo, se muestra el texto del archivo en la card
//Y un boton para quitar el archivo

// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

import 'package:speech_analytics/analizador.dart';
import 'package:speech_analytics/puntuacion.dart';
import 'package:speech_analytics/widgets/puntuacion.dart';
import 'package:speech_analytics/widgets/selector.dart';

class CardTexto extends StatefulWidget {
  final bool esAtencion;
  final String titulo;

  const CardTexto({super.key, required this.titulo, this.esAtencion = false});

  @override
  State<CardTexto> createState() => CardTextoState();
}

class CardTextoState extends State<CardTexto> {
  File? file;
  String? text;
  int activeStep = 0;
  late Analizador analizador;
  final Map<String, Token> palabrasSospechosas = {};
  Puntaje? puntaje;

  @override
  void initState() {
    analizador = Analizador(esAtencion: widget.esAtencion);
    super.initState();
  }

  void _openFileExplorer() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null) return;

      activeStep = 1;

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
      activeStep = 0;
      palabrasSospechosas.clear();
      puntaje = null;
    });
  }

  //Funcion que procesa la entrada
  void procesarEntrada() {
    //Si no hay archivo, no hacer nada
    if (file == null) return;

    //Llamar a la funcion analizarSospechosos con el texto
    final sospechosas = analizador.analizarSospechosos(text!);

    //Guardar las palabras sospechosas en el map de cliente
    for (String palabra in sospechosas) {
      palabrasSospechosas[palabra] = Token.otros;
    }

    //Como todavia no funciona mostramos una imagen de un gatito
    //que dice "no hace nada"
    setState(() {
      activeStep = 2;
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
          EasyStepper(
            activeStep: activeStep,
            showLoadingAnimation: false,
            lineStyle: const LineStyle(lineLength: 80),
            stepShape: StepShape.circle,
            borderThickness: 2,
            stepRadius: 25,
            internalPadding: 10,
            alignment: Alignment.topCenter,
            finishedStepBorderColor: Colors.blue.shade800,
            activeStepIconColor: Colors.blue.shade800,
            unreachedStepBorderColor: Colors.black38,
            unreachedStepIconColor: Colors.black38,
            unreachedStepTextColor: Colors.black38,
            enableStepTapping: false,
            steps: const [
              EasyStep(
                title: 'Seleccionar archivo',
                icon: Icon(Icons.file_copy),
                activeIcon: Icon(Icons.file_copy_outlined),
              ),
              EasyStep(
                  title: 'Procesar archivo',
                  icon: Icon(Icons.analytics),
                  activeIcon: Icon(Icons.analytics_outlined)),
              EasyStep(
                title: 'Seleccionar tokens',
                icon: Icon(Icons.category),
                activeIcon: Icon(Icons.category_outlined),
              ),
              EasyStep(
                title: 'Puntuación',
                icon: Icon(Icons.check),
                activeIcon: Icon(Icons.check_outlined),
              )
            ],
          ),
          if (activeStep == 0) ...[
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
          if (activeStep == 1) ...[
            //Mostrar nombre del archivo
            Text(file!.path.split('/').last),

            const SizedBox(height: 10),

            const SizedBox(height: 15),

            //Mostrar texto del archivo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: TextEditingController(text: text),
                  maxLines: null,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            //Boton para procesar el archivo en la parte del final

            ElevatedButton.icon(
                onPressed: procesarEntrada,
                icon: const Icon(Icons.analytics),
                label: const Text('Procesar archivo')),

            const SizedBox(height: 20),
          ],
          if (activeStep == 2) ...[
            Expanded(
              child: TokenSelector(
                palabras: palabrasSospechosas,
                onSelected: (result) {
                  analizador.actualizarTabla(result);

                  //Obtener puntaje
                  puntaje = analizador.obtenerPuntuacion(text!);
                  setState(
                    () {
                      activeStep = 4;
                    },
                  );
                },
              ),
            ),
          ],
          if (activeStep == 4) ...[
            Expanded(
              child: Puntuacion(
                textspan: analizador.generarRichText(text!, context),
                puntaje: puntaje!,
                onRestart: () {
                  _removeFile();
                },
              ),
            ),
          ]
        ],
      ),
    );
  }
}
