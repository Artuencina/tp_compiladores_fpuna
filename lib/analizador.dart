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

import 'package:speech_analytics/main.dart';

enum Token { bueno, malo, clave, otros }

class Analizador {
  Analizador() {
    //Crear archivo de texto con la tabla de simbolos
    File file = File('tablaSimbolos.txt');
    if (!file.existsSync()) {
      file.createSync();

      //Llenar tabla de simbolos con palabras por defecto
      tablaSimbolos['bueno'] = Token.bueno;
      tablaSimbolos['excelente'] = Token.bueno;
      tablaSimbolos['bien'] = Token.bueno;
      tablaSimbolos['gracias'] = Token.bueno;
      tablaSimbolos['malo'] = Token.malo;
      tablaSimbolos['fue'] = Token.clave;
      tablaSimbolos['es'] = Token.clave;
      tablaSimbolos['un'] = Token.clave;
      tablaSimbolos['una'] = Token.clave;
      tablaSimbolos['muy'] = Token.clave;
      tablaSimbolos['demasiado'] = Token.clave;

      guardarTabla();
    } else {
      cargarPalabras();
    }
  }

  //HashMap que contiene la tabla de simbolos
  final HashMap<String, Token> tablaSimbolos = HashMap<String, Token>();

  void cargarPalabras() {
    //Leer archivo y cargar en la tabla de simbolos
    File file = File('tablaSimbolos.txt');
    List<String> lines = file.readAsLinesSync();
    for (String line in lines) {
      List<String> tokens = line.split(' ');
      tablaSimbolos[tokens[0]] = Token.values[int.parse(tokens[1])];
    }
  }

  //Funcion que se encarga de analizar el texto y ampliar la tabla de simbolos
  List<String> analizarSospechosos(String texto) {
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
          tablaSimbolos[palabras[i]] = Token.otros;

          //Guardar en el archivo
          file.writeAsStringSync(
              '\n${palabras[i]} ${Token.values.indexOf(Token.otros)}',
              mode: FileMode.append);
        }
      }
    }
    return sospechosas;
  } //Fin de la funcion analizarSospechosos

  //Funcion que guarda los valores del hashtable de tablasimbolos en un archivo
  void guardarTabla() {
    File file = File('tablaSimbolos.txt');
    if (!file.existsSync()) {
      file.createSync();
    }
    for (String palabra in tablaSimbolos.keys) {
      file.writeAsStringSync(
          '${tablaSimbolos.keys.first == palabra ? '' : '\n'}$palabra ${Token.values.indexOf(tablaSimbolos[palabra]!)}',
          mode: FileMode.append);
    }
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

      //Agregar a la tabla de simbolos
      tablaSimbolos[palabra] = palabrasNuevas[palabra]!;

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
}
