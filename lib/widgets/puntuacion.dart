//Widget para mostrar la puntuacion del texto, teniendo en cuenta sus palabras
//buenas y malas
//Las palabras que esten mas cerca del final tienen mas peso
//Muestra la cantidad de palabras buenas, malas y un porcentaje final de la puntuacion
//Muestra un rich text con las palabras malas en rojo y las buenas en verde
//Y un boton para volver a empezar

import 'package:flutter/material.dart';

class Puntuacion extends StatelessWidget {
  final List<TextSpan> textspan;
  final int palabrasBuenas;
  final int palabrasMalas;
  final int porcentaje;
  final void Function() onRestart;

  const Puntuacion({
    super.key,
    required this.textspan,
    required this.palabrasBuenas,
    required this.palabrasMalas,
    required this.porcentaje,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Resultado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          //Mostrar porcentaje de resultado con un container circular

          Container(
            width: 100,
            height: 100,
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

          //Si el porcentaje es mayor a 50, mostrar texto de puntuacion buena
          //Si es menor a 50, mostrar texto de puntuacion mala
          //Si es igual a 50, mostrar texto de puntuacion media
          if (porcentaje > 50) ...[
            const SizedBox(height: 10),
            Text(
              'La puntuación es buena',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ] else if (porcentaje < 50) ...[
            const SizedBox(height: 10),
            Text(
              'La puntuación es mala',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              'La puntuación es media',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],

          const SizedBox(height: 10),

          //Mostrar cantidad de palabras buenas y malas
          ListTile(
            leading: const Icon(Icons.check, color: Colors.green),
            title: Text('Palabras buenas: $palabrasBuenas'),
          ),
          ListTile(
            leading: const Icon(Icons.close, color: Colors.red),
            title: Text('Palabras malas $palabrasMalas'),
          ),

          const SizedBox(height: 10),

          //Mostrar texto con palabras buenas y malas
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: RichText(
              text: TextSpan(
                children: textspan,
              ),
            ),
          ),

          //Boton para volver a empezar
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('Volver a empezar'),
            ),
          ),
        ],
      ),
    );
  }
}
