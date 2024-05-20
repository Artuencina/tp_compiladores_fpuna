//Arturo Manuel Encina Jiménez
//CI: 4.960.048

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_analytics/home.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.blue[100]!,
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.robotoTextTheme(),
  fontFamily: GoogleFonts.roboto().fontFamily,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Speech Analyzer',
      theme: theme,
      routes: {
        '/': (context) => const Home(),
      },
      initialRoute: '/',
    );
  }
}
