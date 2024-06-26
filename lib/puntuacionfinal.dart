//Widget scaffold que muestra los resultados del promedio de las puntuaciones
//No muestra el texto de los archivos
//Muestra el porcentaje de la puntuacion final (promedio de los dos)
//Una lista de palabras buenas, lista de palabras malas y los mensajes si es que hay
//Un boton para volver a empezar

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class PuntuacionFinal extends StatelessWidget {
  const PuntuacionFinal({
    super.key,
    required this.porcentaje,
    required this.palabrasBuenas,
    required this.palabrasMalas,
    required this.mensaje,
  });

  final int porcentaje;
  final List<String> palabrasBuenas;
  final List<String> palabrasMalas;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del análisis'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Resultado de la llamada',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),

            //Mostrar porcentaje de resultado con un container circular
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$porcentaje%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            //Resultado de la puntuacion
            if (porcentaje > 50) ...[
              const SizedBox(height: 10),
              Text(
                'La llamada fue buena',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ] else if (porcentaje < 50) ...[
              const SizedBox(height: 10),
              Text(
                'La llamada fue mala',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ] else ...[
              const SizedBox(height: 10),
              Text(
                'La llamada fue neutra',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: 10),

            //Lista con la cantidad de palabras buenas
            ListView.builder(itemBuilder: (context, index) {
              return ListTile(
                title: Text(palabrasBuenas[index]),
                leading: const Icon(Icons.check),
              );
            }),

            const SizedBox(height: 10),

            //Lista con la cantidad de palabras malas
            ListView.builder(itemBuilder: (context, index) {
              return ListTile(
                title: Text(palabrasMalas[index]),
                leading: const Icon(Icons.close),
              );
            }),

            //Mostrar los mensajes
            if (mensaje.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  tileColor: Colors.orange[100],
                  leading: const Icon(Icons.info),
                  title: Text(mensaje,
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
            ],
            const SizedBox(height: 10),

            //Boton para volver a empezar
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Volver a empezar'),
            ),
          ],
        ),
      ),
    );
  }
}
