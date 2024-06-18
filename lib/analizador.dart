//Clase que se encarga de analizar el texto
/*
Funciona de la siguiente manera:
La idea es construir una tabla de símbolos de un compilador, con el lexema,
el token al que pertenece y el lugar en el que se encuentra.
Para ello se utiliza una tabla hash que se va llenando con los lexemas y los tokens.

Se tienen tres tokens: bueno, malo, clave y otros.
En bueno y malo, inicialmente se definen palabras por defecto.
Luego, se pueden agregar palabras a la lista de palabras buenas o malas.
Las palabras que potencialmente sean buenas o malas se marcan como sospechosas
(Palabras que estén al principio, después de una palabra clave como "fue", "es", "un", "una", etc.)
El resto de palabras van al token otros.

Para analizar el texto, se recorre el texto palabra por palabra y se va llenando la tabla de símbolos.
Esto genera un archivo de texto con la tabla de símbolos.
*/

import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speech_analytics/main.dart';
import 'package:speech_analytics/puntuacion.dart';

enum Token { bueno, malo, clave, saludo, saludoCompuesto, otros }

class Analizador {
  Analizador({this.esAtencion = false}) {
    //Crear archivo de texto con la tabla de simbolos
    File file = File('tablaSimbolos.txt');
    if (!file.existsSync()) {
      file.createSync();

      inicializarPalabras();
    }
  }

  //Variable que indica si el analizador es para el cliente o el de atencion
  bool esAtencion;

  //Funcion que lee un archivo txtinicial.txt y lo guarda en tablasimbolos.txt
  void inicializarPalabras() {
    File file = File('tablaSimbolos.txt');
    File fileInicial = File('txtinicial.txt');
    List<String> lines = fileInicial.readAsLinesSync();
    file.writeAsStringSync(lines.join('\n'));
  }

  //Funcion que lee una tabla de simbolos y lo guarda en un hashtable
  HashMap<String, Token> cargarPalabras() {
    //Leer archivo y cargar en la tabla de simbolos
    HashMap<String, Token> tablaSimbolos = HashMap();
    File file = File('tablaSimbolos.txt');

    //Si no existe, inicializar
    if (!file.existsSync()) {
      inicializarPalabras();
    }

    List<String> lines = file.readAsLinesSync();
    for (String line in lines) {
      List<String> tokens = line.split(' ');

      //Cargar
      tablaSimbolos[tokens[0]] = Token.values[int.parse(tokens[1])];
    }
    return tablaSimbolos;
  }

  //Funcion que se encarga de analizar el texto y ampliar la tabla de simbolos
  List<String> analizarSospechosos(String texto) {
    //Tabla de simbolos
    final HashMap<String, Token> tablaSimbolos = cargarPalabras();

    File file = File('tablaSimbolos.txt');
    //Quitar los signos de puntuacion
    texto = limpiarTexto(texto);

    List<String> palabras = texto
        .split(RegExp(r'\s+'))
        .where((element) => element.isNotEmpty)
        .toList();
    final List<String> sospechosas = [];
    //Recorrer el texto palabra por palabra
    for (int i = 0; i < palabras.length; i++) {
      //Si la palabra es clave, la palabra siguiente se agrega como sospechosa
      if (tablaSimbolos.containsKey(palabras[i])) {
        //Si la palabra siguiente no está en la tabla de simbolos, se agrega como sospechosa
        if (tablaSimbolos[palabras[i]] == Token.clave &&
            i + 1 <= palabras.length &&
            !tablaSimbolos.containsKey(palabras[i + 1])) {
          sospechosas.add(palabras[i + 1]);
        }
      } else {
        //Si no está en la tabla de simbolos, se agrega como otros
        //Se verifica que no sea sospechosa
        if (!sospechosas.contains(palabras[i])) {
          //Guardar en el archivo
          file.writeAsStringSync(
              '\n${palabras[i]} ${Token.values.indexOf(Token.otros)}',
              mode: FileMode.append);
        }
      }
    }
    return sospechosas;
  } //Fin de la funcion analizarSospechosos

  //Funcion que obtiene la puntuación de un texto y devuelve un objeto puntuacion
  //con puntos buenos, malos y un porcentaje
  Puntaje? obtenerPuntuacion(String texto) {
    texto = limpiarTexto(texto);
    final HashMap<String, Token> tablaSimbolos = cargarPalabras();
    bool haySaludo = false;
    bool hayDespedida = false;
    int buenos = 0;
    int palabrasbuenas = 0;
    int malos = 0;
    int palabrasMalas = 0;

    //Separamos el texto en lineas
    List<String> lineas =
        texto.split('\n').where((element) => element.isNotEmpty).toList();

    //Luego, recorremos cada palabra de la linea
    for (int i = 0; i < lineas.length; i++) {
      List<String> palabras = lineas[i].split(RegExp(r'\s+'));

      for (int j = 0; j < palabras.length; j++) {
        final palabra = palabras[j];
        //Si la palabra esta vacia, ignoramos
        if (palabra.isEmpty) continue;

        //Verificamos el token
        final token = tablaSimbolos[palabra];

        //Si el token es NULL, hay un error.
        if (token == null) {
          return null;
        }

        //Si es analizador de atencion, hay que corroborar que se tengan
        //saludos y despedidas.
        //Los saludos y despedidas compuestas comprueban la siguiente palabra
        //Si no hay ambos, se considera un error y se suman puntos malos
        if (esAtencion) {
          //Comprobar que al inicio haya un saludo
          if (i == 0) {
            if (token == Token.saludo) {
              haySaludo = true;
            }
            if (token == Token.saludoCompuesto && j + 1 < palabras.length) {
              if (tablaSimbolos[palabras[j + 1]] == Token.saludoCompuesto) {
                haySaludo = true;
              }
            }
          }

          //Comprobar que al final haya una despedida
          if (i == lineas.length - 1) {
            if (token == Token.saludo) {
              hayDespedida = true;
            }
            if (token == Token.saludoCompuesto && j + 1 < palabras.length) {
              if (tablaSimbolos[palabras[j + 1]] == Token.saludoCompuesto) {
                hayDespedida = true;
              }
            }
          }
        }

        //Aumentar la cantidad de puntos teniendo en cuenta que
        //las palabras encontradas en lineas posteriores
        //tienen mas peso
        if (Token.values.indexOf(token) < 2) {
          if (token == Token.bueno) {
            buenos += i + 1;
            palabrasbuenas++;
          } else {
            malos += i + 1;
            palabrasMalas++;
          }
        }
      }
    }

    //Si es analizador de atencion, se verifica que haya saludo y despedida
    String mensaje = '';
    if (esAtencion) {
      if (!haySaludo) {
        mensaje += 'No se encontró un saludo al inicio del texto. ';
        malos += 5;
      }
      if (!hayDespedida) {
        mensaje += 'No se encontró una despedida al final del texto. ';
        malos += 5;
      }
    }

    int porcentaje =
        ((buenos + malos) == 0 ? 100 : 100 * buenos / (buenos + malos)).toInt();

    //Obtenemos el porcentaje
    return Puntaje(
        puntosBuenos: palabrasbuenas,
        puntosMalos: palabrasMalas,
        porcentaje: porcentaje,
        mensaje: mensaje);
  }

  //Funcion que recibe un Map con las palabras y su token y lo guarda en un archivo de texto
  void actualizarTabla(Map<String, Token> palabrasNuevas) {
    File file = File('tablaSimbolos.txt');
    if (!file.existsSync()) {
      file.createSync();
    }

    //Guardar las palabras nuevas en el archivo
    for (String palabra in palabrasNuevas.keys) {
      final intToken = Token.values.indexOf(palabrasNuevas[palabra]!);

      //Agregamos la palabra, su version masculina, femenina y plural
      file.writeAsStringSync('\n$palabra $intToken', mode: FileMode.append);

      //Agregar version en plural
      if (!palabra.endsWith('s')) {
        file.writeAsStringSync('\n${palabra}s $intToken',
            mode: FileMode.append);
      }

      //Si la palabra termina en "a", se agrega la version masculina
      if (palabra.endsWith('a')) {
        String masculino = '${palabra.substring(0, palabra.length - 1)}o';
        file.writeAsStringSync('\n$masculino $intToken', mode: FileMode.append);
        file.writeAsStringSync('\n${masculino}s $intToken',
            mode: FileMode.append);
      } else {
        //Si la palabra termina en "o", se quita la "o" y se agrega la version femenina
        if (palabra.endsWith('o')) {
          String femenino = '${palabra.substring(0, palabra.length - 1)}a';
          file.writeAsStringSync('\n$femenino $intToken',
              mode: FileMode.append);
          file.writeAsStringSync('\n${femenino}s $intToken',
              mode: FileMode.append);
        } else {
          String femenino = '${palabra}a';
          file.writeAsStringSync('\n$femenino $intToken',
              mode: FileMode.append);
          file.writeAsStringSync('\n${femenino}s $intToken',
              mode: FileMode.append);
        }
      }
    }
  }

  //Funcion que recibe un texto y genera un widget richtext con las palabras buenas y malas
  List<TextSpan> generarRichText(String texto, BuildContext context) {
    //Tabla de simbolos
    final HashMap<String, Token> tablaSimbolos = cargarPalabras();
    //Limpiar el texto
    //texto = limpiarTexto(texto);

    //Separar el texto en lineas
    List<String> lineas =
        texto.split('\n').where((element) => element.isNotEmpty).toList();

    //Lista de widgets
    List<TextSpan> widgets = [];

    //Recorrer cada linea
    for (int i = 0; i < lineas.length; i++) {
      List<String> palabras = lineas[i].split(RegExp(r'\s+'));

      //Recorrer cada palabra
      for (int j = 0; j < palabras.length; j++) {
        final palabra = palabras[j];
        //Si la palabra esta vacia, ignoramos
        if (palabra.isEmpty) continue;

        //Verificamos el token
        final token = tablaSimbolos[limpiarTexto(palabra)];
        bool esSaludoCompuesto = false;

        //Comprobar si es saludo compuesto
        if (esAtencion && token == Token.saludoCompuesto) {
          //Verificar si la siguiente palabra es saludo compuesto
          if (j + 1 < palabras.length &&
              tablaSimbolos[limpiarTexto(palabras[j + 1])] ==
                  Token.saludoCompuesto) {
            esSaludoCompuesto = true;
          }
          //Verificar si la palabra anterior es saludo compuesto
          if (j - 1 >= 0 &&
              tablaSimbolos[limpiarTexto(palabras[j - 1])] ==
                  Token.saludoCompuesto) {
            esSaludoCompuesto = true;
          }
        }

        //Si el token es NULL, hay un error.
        if (token == null) {
          return [];
        }

        //Agregamos el texto a la lista de widgets
        widgets.add(TextSpan(
            text: '$palabra ',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: token == Token.bueno
                    ? Colors.green
                    : token == Token.malo
                        ? Colors.red
                        : token == Token.saludo || esSaludoCompuesto
                            ? Colors.orange
                            : Colors.black)));
      }
      widgets.add(const TextSpan(text: '\n'));
    }

    //Retornamos el widget
    return widgets;
  }
}
