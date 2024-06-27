//Pantalla que recibe dos archivos de texto (Atencion al cliente y
//experiencia de usuario) y los muestra en la pantalla
//Al final hay un boton que dice analizar y lleva a la pantalla de analisis

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'package:speech_analytics/widgets/cardtexto.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int stepExperiencia = 0;
  int stepAtencion = 0;

  //Funcion que verifica si puede continuar
  bool _puedeContinuar() {
    return stepAtencion == 3 && stepExperiencia == 3;
  }

  //Keys para obtener el analizador de cada cartexto
  final GlobalKey<CardTextoState> keyAtencion = GlobalKey();
  final GlobalKey<CardTextoState> keyExperiencia = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Analyzer'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          //Boyon que abre el archivo de tabla de simbolos
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () async {
              //Abrir archivo
              await OpenFile.open("tablaSimbolos.txt");
            },
          ),
          //Boton de informacion
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              //Mostrar informacion
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    actions: [
                      TextButton(
                        child: const Text("Cerrar"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Speech Analyzer"),
                        Text("Desarrollado por: Arturo Encina"),
                        Text("CI: 4.960.048"),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CardTexto(
                      key: keyAtencion,
                      step: stepAtencion,
                      titulo: "Atencion al cliente",
                      esAtencion: true,
                      addStep: () {
                        setState(() {
                          stepAtencion++;
                        });
                      },
                      reset: () {
                        setState(() {
                          stepAtencion = 0;
                        });
                      }),
                ),
                //Divisor vertical
                const VerticalDivider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Expanded(
                  child: CardTexto(
                    key: keyExperiencia,
                    step: stepExperiencia,
                    titulo: "Experiencia de cliente",
                    esAtencion: false,
                    addStep: () {
                      setState(() {
                        stepExperiencia++;
                      });
                    },
                    reset: () {
                      setState(() {
                        stepExperiencia = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      //Boton de analisis
      floatingActionButton: _puedeContinuar()
          ? FloatingActionButton(
              onPressed: () {
                //Mostrar un dialog con la puntuacion final en un container circular
                final puntajeAtencion = keyAtencion.currentState!.puntaje;
                final puntajeExperiencia = keyExperiencia.currentState!.puntaje;

                //Calcular el puntaje final
                final puntajeFinal = (puntajeAtencion!.porcentaje +
                        puntajeExperiencia!.porcentaje) /
                    2;

                //Mostrar el dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Puntaje final"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${puntajeFinal.toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),

                          //Mostrar si la puntuacion fue buena, mala o neutra
                          if (puntajeFinal < 40)
                            const Text(
                              "La llamada fue mala",
                            )
                          else if (puntajeFinal < 60)
                            const Text(
                              "La llamada fue neutra",
                            )
                          else
                            const Text(
                              "La llamada fue buena",
                            ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text("Reiniciar"),
                        ),
                      ],
                    );
                  },
                ).then((value) => {
                      if (value ?? false)
                        {
                          keyAtencion.currentState!.removeFile(),
                          keyExperiencia.currentState!.removeFile(),
                        }
                    });
              },
              child: const Icon(Icons.analytics),
            )
          : null,
    );
  }
}
