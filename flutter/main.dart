import 'package:flutter/material.dart';
import 'home/home_screen.dart'; 

// We add a simple global notifier to listen for dark mode changes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Bistro App',
          debugShowCheckedModeBanner: false, 
          themeMode: currentMode, // Tells the app which mode is currently active
          
          // Your original Light Theme
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF800000),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto', 
          ),
          
          // The new Dark Theme
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF800000),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212), // Standard dark background
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          
          home: const HomeScreen(), 
        );
      },
    );
  }
}