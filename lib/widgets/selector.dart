//Widget antes del resultado que muestra las palabras sospechosas y permite
//al usuario elegir un token para cada una

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_analytics/analizador.dart';

class TokenSelector extends StatefulWidget {
  final Map<String, Token> palabras;
  final HashMap<String, Token> otrasPalabras;
  final void Function(Map<String, TokenValor>) onSelected;

  const TokenSelector({
    super.key,
    required this.palabras,
    required this.onSelected,
    required this.otrasPalabras,
  });

  @override
  State<TokenSelector> createState() => _TokenSelectorState();
}

class _TokenSelectorState extends State<TokenSelector> {
  late final List<String> keys;
  late final List<Token> tokens;
  late final List<double> values;
  late HashMap<String, Token> otrasPalabras;
  bool mostrarTodo = false;

  final List<IconData> icons = [
    Icons.check,
    Icons.close,
    Icons.key,
    Icons.waving_hand,
    Icons.waving_hand,
    Icons.error,
    Icons.credit_card,
  ];

  @override
  void initState() {
    super.initState();
    otrasPalabras = HashMap.from(widget.otrasPalabras);
    keys = widget.palabras.keys.toList();
    tokens = List.generate(keys.length, (index) => Token.otros);
    values = List.generate(keys.length, (index) => 0);
  }

  //Funcion para mostrar todas las palabras. Lo que hace es agregar todas las palabras
  //a la lista de keys, tokens y values. Luego, se llama a setState para que se actualice
  void mostrarTodas() {
    keys.addAll(otrasPalabras.keys);
    tokens.addAll(List.filled(otrasPalabras.length, Token.otros));
    values.addAll(List.filled(otrasPalabras.length, 0));
    otrasPalabras.clear();
    setState(() {
      mostrarTodo = true;
    });
  }

  //Funcion inversa que oculta todo lo que no sea sospechoso de la lista de keys, tokens y values
  void ocultarOtras() {
    otrasPalabras = HashMap.from(widget.otrasPalabras);
    for (var key in otrasPalabras.keys) {
      //Obtener el indice y eliminarlo de las listas
      final index = keys.indexOf(key);
      keys.removeAt(index);
      tokens.removeAt(index);
      values.removeAt(index);
    }
    setState(() {
      mostrarTodo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (keys.isEmpty)
          const Expanded(
            child: Center(child: Text("No hay palabras sospechosas")),
          ),
        if (keys.isNotEmpty) ...[
          Text('Palabras sospechosas:',
              style: Theme.of(context).textTheme.titleLarge),
          Text('Seleccione el token que corresponde a cada palabra',
              style: Theme.of(context).textTheme.bodyLarge),
          //Boton para mostrar todas las palabras
          ElevatedButton(
            onPressed: mostrarTodo ? ocultarOtras : mostrarTodas,
            child: Text(mostrarTodo ? 'Ocultar otras' : 'Mostrar todas'),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(icons[tokens[index].index]),
                  title: Text(keys[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<Token>(
                        value: tokens[index],
                        onChanged: (value) {
                          setState(() {
                            tokens[index] = value!;
                          });
                        },
                        items: Token.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toString().split('.').last),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(width: 10),
                      //Elegir un valor numerico para la palabra
                      TextField(
                        decoration: const InputDecoration(
                          constraints: BoxConstraints(maxWidth: 50),
                          labelText: 'Valor',
                          counterText: '',
                        ),
                        //Formateador numerico
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final double valor = double.tryParse(value) ?? 0;
                          setState(() {
                            values[index] = valor;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: ElevatedButton.icon(
            onPressed: () {
              final Map<String, TokenValor> result = {};
              for (int i = 0; i < keys.length; i++) {
                result[keys[i]] =
                    TokenValor(token: tokens[i], valor: values[i]);
              }

              //Agregar las otras palabras
              for (final entry in otrasPalabras.entries) {
                result[entry.key] = TokenValor(token: Token.otros, valor: 0);
              }

              widget.onSelected(result);
            },
            icon: const Icon(Icons.save),
            label: const Text('Continuar'),
          ),
        ),
      ],
    );
  }
}
