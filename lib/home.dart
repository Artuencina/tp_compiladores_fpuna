//Pantalla que recibe dos archivos de texto (Atencion al cliente y
//experiencia de usuario) y los muestra en la pantalla
//Al final hay un boton que dice analizar y lleva a la pantalla de analisis

import 'package:flutter/material.dart';
import 'package:tp_compiladores_fpuna/widgets/cardtexto.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Analyzer'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
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
                    onFileSelected: (p) {},
                    titulo: "Atencion al cliente",
                  ),
                ),
                //Divisor vertical
                const VerticalDivider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Expanded(
                  child: CardTexto(
                    onFileSelected: (p) {},
                    titulo: "Experiencia de cliente",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/analyze');
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}