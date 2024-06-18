//Widget antes del resultado que muestra las palabras sospechosas y permite
//al usuario elegir un token para cada una

import 'package:flutter/material.dart';
import 'package:speech_analytics/analizador.dart';

class TokenSelector extends StatefulWidget {
  final Map<String, Token> palabras;
  final void Function(Map<String, Token>) onSelected;

  const TokenSelector({
    super.key,
    required this.palabras,
    required this.onSelected,
  });

  @override
  State<TokenSelector> createState() => _TokenSelectorState();
}

class _TokenSelectorState extends State<TokenSelector> {
  late final List<String> keys;
  late final List<Token> tokens;

  final List<IconData> icons = [
    Icons.check,
    Icons.close,
    Icons.key,
    Icons.waving_hand,
    Icons.waving_hand,
    Icons.error,
  ];

  @override
  void initState() {
    super.initState();
    keys = widget.palabras.keys.toList();
    tokens = List.filled(keys.length, Token.otros);
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
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(icons[tokens[index].index]),
                  title: Text(keys[index]),
                  trailing: DropdownButton<Token>(
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
                );
              },
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: ElevatedButton.icon(
            onPressed: () {
              final Map<String, Token> result = {};
              for (int i = 0; i < keys.length; i++) {
                result[keys[i]] = tokens[i];
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
