//IM_2021_006 - K D N Rasanjana
import 'package:flutter/material.dart'; //Flutter Material package to use its widgets and UI components
import 'package:calculator_app/calculator_screen.dart'; //CalculatorScreen class from a separate file for the calculator screen implementation

// entry point of the application
void main() {
  runApp(const MyApp()); // runs the app by calling the MyApp widget
}

// Defining the main widget of the application.
class MyApp extends StatelessWidget {
  const MyApp(
      {super.key}); // Constructor for MyApp marked as const to optimize widget rebuilding

  // build method describes the UI of this widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Calculator App', // title used for debugging and identification
      debugShowCheckedModeBanner: false,

      // Sst the theme of the application.
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          // Customizing the appearance of elevated buttons globally
          style: ElevatedButton.styleFrom(
            foregroundColor: Color.fromRGBO(
                82, 91, 68, 1), // sets the text color of the button
            backgroundColor: Color.fromRGBO(
                241, 240, 232, 1), // set the background color of the button
            shape: const CircleBorder(), // makes the button round
            textStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
            elevation:
                0.3, // add a shadow effect to the button with an elevation value
            minimumSize: Size(80, 80), // minimum size of the button
          ),
        ),
      ),
      // Specifies the CalculatorScreen widget as the home screen of the app.
      home: const CalculatorScreen(),
    );
  }
}
